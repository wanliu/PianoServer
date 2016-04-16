require 'machine'

class SeedMachine < Machine
  # include Singleton

  attr_accessor :one_money, :item, :status, :code, :message, :current_user, :options
  attr_reader :context, :result, :env
  cattr_reader :setup_options

  def initialize(action_context, _options = {})
    super
    @context = action_context
    @options = _options
    @seed = _options[:seed] if _options[:seed]
  end

  def conditions
    [
      :condition_share_seed?,
      :condition_in_period?,
      :condition_seed_valid?,
      :condition_remind_seed?,
    ]
  end

  # 判断本活动是不是可以分享购买
  def condition_share_seed?

    if one_money.shares > 0
      if @seed
        true
      else
        status "dont_have_seed"
        error "you dont have seed of share,so cant grab again %d" % [item.id], 400
      end
    else
      @env[:skip_seed] = true
      true
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
      error "you seed %d must be not used" % [seed.id], 400
    elsif @seed.expired? # 是否过期
      status "seed_expired"
      error "seed is expired"
    elsif @seed.owner && @seed.owner.id != current_user.id # 是否给用户的种子
      status "seed_invalid_owner"
      error "is not your seed %d" % [seed.id], 400
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
      error "more than %d limit of seeds" % one_money.share_seed
    else
      true
    end
  end
end
