class GrabMachine
  # include Singleton

  attr_accessor :one_money, :item, :status, :code, :message, :current_user, :options

  attr_reader :context, :body, :env
  cattr_reader :setup_options

  def initialize(action_context, _options = {})
    @context = action_context
    @options = _options
  end

  def run(_one_money, _item, &block)
    reset
    @one_money = _one_money
    @item = _item
    @code = 200
    @env = {}

    grab_conditions.each do |condition_method|
      # @one_money = one_money
      # @item = item

      next_if = begin
                  self.__send__(condition_method)
                rescue => exception
                  status "unknown"
                  @body = body.merge({
                    backtrace: exception.backtrace.join("\n")
                  }) unless Rails.env.production?
                  error exception.to_s
                end
      # pp condition_method, next_if, @code, status, error

      break unless next_if
    end

    if @code >= 200 and @code < 300
      yield (self) if block_given?
    else
      context.render(json: body, status: @code)
    end

    self
  end

  def _run(_one_money, _item, &block)

  end

  def self.run(context, one_money, item, &block)
    machine = GrabMachine.new(context, self.setup_options)
    machine.run(one_money, item, &block)
  end

  def self.finalize(machine)
    proc { puts 'finalize'; machine.reset; machine.options = nil }
  end

  def self.setup(_options = {})
    @setup_options = _options
  end

  def self.setup_options
    @setup_options ||= {}
  end

  protected

  def current_user
    @current_user ||= context.send(__user_method)
  end

  def reset
    # @one_money = nil
    # @item = nil
    # @current_user = nil
    @status = nil
    @code = nil
    @message = nil
    # @options = {}

  end

  def grab_conditions
    [
      :condition_status?,
      :condition_total_amount?,
      :condition_quantity?,
      :condition_price?,
      :condition_parent?,
      :condition_winner?,
      :condition_multiple?,
      :condition_executies?,
      :condition_insufficient?
    ]
  end

  def __user_method
    @options[:user_method] || :current_user
  end

  def body(_body = nil)
    if _body.nil?
      @body ||= {}
      @body[:error] = error[:error]
      @body[:status] = status
      @body
    else
      @body = _body
    end
  end
  # 判断状态是不是开始，只在生产模式
  def condition_status?
    if Rails.env.production?
      if item.status == "started"
        true
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
      winner = one_money.winners.find(user_id: current_user.id).first

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

  # 判断是否支持多种 Item 抢购， 如果  multi_item 没有设置，那么此活动只能抢够一次一件商品
  # 只有 multi_item > 1 时才会触发多个 Item 的抢购次数的检查。
  def condition_multiple?
    return true if @env[:skip_multiple]

    multi_item = one_money.multi_item

    grabs = PmoGrab
      .find(user_id: current_user.id, one_money: one_money.id)
      .combine(item_id: one_money.items.ids)

    grab_groups = grabs.group_by {|grab| grab.item_id }
    always_multi = grab_groups.keys.count
    if always_multi < multi_item
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

    max_executies = item.max_executies || 1

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
      true
    else
      status "insufficient"
      error "Grap this OneMoney dont have inventory"
    end
  end

  def error(message = nil, _code = 500)
    if message.nil?
      @error || {}
    elsif message.is_a? String
      @error = {
        error:  message
      }
      @code = _code
      false
    elsif message.is_a? Hash
      @error = message
      @code = _code
      false
    else
      false
    end
  end

  def status(_status = nil)
    if _status.nil?
      @status
    else
      @status = _status
    end
  end
end
