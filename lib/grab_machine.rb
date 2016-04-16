require 'machine'

class GrabMachine < Machine
  # include Singleton

  attr_accessor :one_money, :item

  # attr_reader :context, :result, :env
  # cattr_reader :setup_options

  def self.run(context, one_money, item, options = {}, &block)
    machine = self.new(context, self.setup_options)
    machine.run({
      one_money: one_money,
      item: item
    }.merge(options), &block)
  end

  protected

  def before_run(options)
    super

    @one_money = options[:one_money]
    @item = options[:item]
    @seed = options[:seed] if options[:seed]
  end

  def conditions
    [
      :condition_status?,
      :condition_total_amount?,
      :condition_quantity?,
      :condition_price?,
      :condition_parent?,
      # :condition_winner?,
      :condition_share_seed?, # if
      :condition_available_seed?,
      :condition_in_period?,
      :condition_seed_valid?,
      :condition_remind_seed?,

      :condition_multiple?, # or
      :condition_executies?,
      :condition_insufficient?
    ]
  end

  # 判断状态是不是开始，只在生产模式
  def condition_status?
    if Rails.env.production?
      if item.status == "started"
        true
      elsif item.status == "suspend"
        status "suspend"
        error 'item has be suspend.'
      elsif item.status == "end"
        status "end"
        error 'item is stop.'
      elsif item.status == "timing" || item.status.blank?
        status "waiting"
        error 'acitvity no started.'
      else
        status "state-invalid"
        error 'must at started status'
      end
    else
      true
    end
  end

  # 检查数据是否完整，
  def condition_total_amount?
    if item.total_amount > 0
      true
    else
      status "total_amount_zero"
      error 'total_amount must great than 0', 422
    end
  end

  def condition_quantity?
    if item.quantity.nil?
      item.quantity = 1
      true
    elsif item.quantity > 0
      true
    else
      status "quantity_zero"
      error 'quantity must great than 0', 422
    end
  end

  def condition_price?
    if item.price < 0
      status "price_zero"
      error "price %.2f must great then 0" % [item.price], 422
    elsif item.price < item.ori_price
      true
    else
      status "price_too_large"
      error "price: %.2f must less than ori_price: %.2f " % [item.price, item.ori_price], 422
    end
  end

  # 是否存在 OneMoney
  def condition_parent?
    @one_money = item.one_money

    if @one_money.present?
      true
    else
      error "dont have parent with item :%d " % [item.id]
    end
  end

  # 判断用户是否已经赢得过这个 Item 的活动了
  def condition_winner?
    multi_item = one_money.multi_item
    case multi_item
    when nil, 0, 1
      winner = one_money.winners.find(user_id: current_user.user_id).first

      if winner.present?
        status "always"
        error "you always winner this OneMoney %d" % [one_money.id], 400
      else
        @env[:skip_multiple] = true
        true
      end
    else
      true
    end
  end

  # 判断本活动是不是可以分享购买
  def condition_share_seed?
    @env[:skip_seed] = true unless one_money.shares > 0
    true
  end

  def condition_available_seed?
    return true if @env[:skip_seed]

    if @seed
      true
    else
      @env[:skip_seed] = true
      true
      # status "dont_have_seed"
      # error "you dont have seed of share,so cant grab again %d" % [item.id], 400
    end
  end

  # 判断是否在有效分享期内
  def condition_in_period?
    return true if @env[:skip_seed]

    if PmoSeed.last_period(current_user, one_money) < one_money.shares
      true
    else
      status "limit_shares"
      error "you cant over shares number %d" % [one_money.shares], 400
    end
  end

  # 是否种子被使用过
  def condition_seed_valid?
    return true if @env[:skip_seed]

    if @seed.used
      status "used_seed"
      error "you seed %d must be not used" % [@seed.id], 400
    elsif @seed.expired? # 是否过期
      status "seed_expired"
      error "seed is expired", 400
    elsif not @seed.given
      status "dont_send"
      error "seed must given another to be work", 400
    elsif @seed.owner_id != current_user.id # 是否给用户的种子
      status "seed_invalid_owner"
      error "is not your seed %d" % [@seed.id], 400
    else
      true
    end
  end

  # 是否超过了种子数
  def condition_remind_seed?
    return true if @env[:skip_seed]

    seeds = PmoSeed.find(one_money: one_money.id, period: @seed.period, owner_id: current_user.id)
    seed_count = seeds.select{ |seed| seed.used }.length

    if seed_count >= one_money.share_seed
      status "limit_seed"
      error "more than %d limit of seeds" % one_money.share_seed, 400
    else
      @env[:skip_multiple] = true
      true
    end
  end

  # 判断是否支持多种 Item 抢购， 如果  multi_item 没有设置，那么此活动只能抢够一次一件商品
  # 只有 multi_item > 1 时才会触发多个 Item 的抢购次数的检查。
  def condition_multiple?
    return true if @env[:skip_multiple]

    multi_item = [one_money.multi_item, 1].max
    grabs = PmoGrab
      .find(user_id: current_user.id, one_money: one_money.id)
      .combine(pmo_item_id: one_money.items.ids)

    grab_groups = grabs.group_by {|grab| grab.pmo_item_id }
    always_multi = grab_groups.keys.count + (grab_groups.keys.include?(item.id.to_s) ? 0 : 1)

    if always_multi <= multi_item
      true
    else
      status 'lack-multi-item'
      error 'not have more item types'
    end
  end

  # 判断是还能够参与活动，通常在于用于检查已经参于过的用户，
  # 某些活动可能可以设置多次参与活动，设置 OneMonay multi_item = 3, 那么用户
  # 可以参于这个活动中，3种 Item 的抢购， 同样也可以设置一个 Item 能抢购几次
  # PmoItem max_executies = 2 , 你可以抢购同样的这款商品 2 次
  def condition_executies?
    return true if @env[:skip_multiple]

    max_executies = [item.max_executies, 1].max

    grabs = item.grabs.find user_id: current_user.id
    always_executies = grabs.count

    if always_executies < max_executies # have executies
      true
    else
      status 'no-executies'
      error 'have note more executies'
    end
  end

  # 用于在抢购时，检查是否库存不足
  def condition_insufficient?
    if item.completes + item.quantity <= item.total_amount
      # pp item.completes, item.quantity, item.total_amount
      true
    else
      status "insufficient"
      error "Grap this OneMoney dont have inventory"
    end
  end
end
