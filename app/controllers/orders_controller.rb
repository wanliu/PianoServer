class OrdersController < ApplicationController
  PROMPTS = {
    ALL: '$key从 $src 变更为 $dest ',
    ADD_ITEMS: '添加 $name ，价格： $price ，数量： $amount ',
    REMOVE_ITEMS: '移除 $name ，价格： $price ，数量： $amount '
  }

  PROMPT_MATCHS = {
    ALL: '*',
    ITEMS: /items\[(\d+)\]\.(\w+)/
  }

  class OrderInvalidState < StandardError; end

  before_action :set_order_params,
    only: [:show, :status, :update, :diff, :accept, :ensure,
            :cancel, :reject, :items, :add_item, :set_address]

  def show
    # if params[:inline]
    #   render json: { order: @order, html: :partial => "order" }
    # else
    #   render json: { order: @order.origin_hash }
    # end
  end

  def status
    response = {
      state: @order.state
    }

    response.merge!(url: @order.avatar_url) if @order.state == :done or @order.state == "done"

    respond_to do |format|
      format.json do
        render json: response
      end
    end
  end

  def update
    begin
      # 应用修改记录， 返回一个新的 json
      new_json    = @order.apply_patch(patch_params)

      # 用差分算法比较两个同的 hash, 返回 diff 数组
      @diffs = diff_hash @order.update_hash, new_json
      unless @diffs.blank?
        @order.updates = new_json
        @order.save
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace.join("\n")
      @diffs = []
    ensure
      send_diff_message @diffs
      render json: { diff: @diffs }
    end
  end

  def set_address
    old_address = @order.delivery_address_title

    delivery_address = params[:delivery_address]
    pp delivery_address

    if delivery_address[:location_id].to_i > 0
      @order.delivery_location_id = delivery_address[:location_id]
    else
      @order[:data] ||= {}
      @order[:data]["delivery_address"] = delivery_address
    end

    @order.save

    new_address = @order.delivery_address_title

    msg = modify_order('delivery_address', old_address, new_address)

    MessageSystemService.push_message current_anonymous_or_user.id, other_side, msg, to: [other_side], type: 'order'
    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order-address', dest: new_address}.to_json

    # render json: @order.delivery_location
    head :ok
  end

  def diff
    @diffs = diff_hash @order.origin_hash, @order.update_hash
    render json: { diff: @diffs }
  end

  def accept
    if @order.accept_state != "accepting"
      @order.update(:accept_state => "accepting")
      MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'accepting'}.to_json
    else
      throw OrderInvalidState.new("invalid accept_state #{@order.accept_state} in accepting")
    end
    render json: { accept_state: @order.accept_state }
  end

  def ensure
    update_hash = @order.update_hash
    if @order.accept_state == 'accepting'
      update_hash["accept_state"] = "accept"
      @order.update(accept_state: "accept")
      @order.update_patch(update_hash)
      # @order.items_attributes = update_hash["items"]
      # @order.save

      MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'accept'}.to_json
    else
      throw OrderInvalidState.new 'This accepting order job is cancel.'
    end

    params[:inline] = true
    render :show, formats: [:json]

    # render json: { accept_state: @order.accept_state }
  end

  def cancel
    @order.update(:accept_state => "cancel")
    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'cancel'}.to_json
    render json: { accept_state: @order.accept_state }
  end

  def reject
    @order.update(:accept_state => "reject")
    @order.update(updates: nil)
    msg = '拒绝了提交的修改'

    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'reject'}.to_json

    MessageSystemService.push_message current_anonymous_or_user.id, other_side, msg, to: [other_side], type: 'order'

    render :show, formats: [:json]
  end

  def items
    # @order.supplier.
    @items = []
  end

  def add_item
  end

  private

  # 获取 order 对象
  def set_order_params
    @order = Order.find(params[:id])
  end

  #将 params 数字为 key 的 hash 转换成 Array
  def patch_params
    params[:patch] # .map { |k, v| v }
  end

  def diff_hash(one, two)
    HashDiff.best_diff one, two
  end

  def other_side
    if @order.buyer_id == current_anonymous_or_user.id
      @order.seller_id || @order.supplier.owner_id
    else
      @order.buyer_id
    end
  end

  def send_diff_message(diffs)
    user_id = current_anonymous_or_user.id
    index = nil
    diff_items = {}
    msg_ary = []
    msg = nil

    return if diffs.empty?

    diffs.each do |op, path, src, dest|
      msg = case op
          when '+' then add_order_item_message(src)
          when '~' then update_order_message(diff_items, path, src, dest)
          end

      unless msg.nil?
        msg_ary.push(msg)
      end
    end

    unless diff_items.empty?
      diff_items.each do |key, item|
        name = item[:name]
        price = item["price"]
        amount = item["amount"]
        prompt = PROMPTS[:ALL]
        msgs = [name, '的']

        unless price.blank?
          msgs.push(generate_prompt(prompt, 'price', price))
        end

        unless amount.blank?
          msgs.push(generate_prompt(prompt, 'amount', amount))
        end

        msg = msgs.join('')
      end

      msg_ary.unshift(msg)
    end

    return if msg_ary.length == 0

    if msg_ary.length > 1
      msg = msg_ary.join('；')
    else
      msg = msg_ary.join('')
    end

    MessageSystemService.push_message user_id, other_side, msg, to: [other_side], type: 'order'
    MessageSystemService.push_command user_id, other_side, {command: 'order', diff: diffs}.to_json
  end

  def update_order_message(diff_items, path, src, dest)
    if path =~ PROMPT_MATCHS[:ITEMS]
      modify_order_items(diff_items, path, src, dest)
    else
      modify_order(path, src, dest)
    end
  end

  def modify_order_items(diff_items, path, src, dest)
    m = path.match(PROMPT_MATCHS[:ITEMS])
    index, key = m[1].to_i, m[2]
    order_item = @order.items[index]

    if key == "deleted" && src == false && dest == true
      return remove_order_item_message(order_item)
    end

    diff_item = diff_items[index] ||= {}
    diff_item[:name] = order_item.title

    item = diff_item[key] ||= {}

    item[:src] = src if item[:src].blank?
    item[:dest] = dest

    nil
    # name, key = @order.items[index].title, OrderItem.human_attribute_name(m[2])
    # prompt = PROMPTS[:ITEMS]
  end

  def modify_order(path, src, dest)
    prompt_template(PROMPTS[:ALL], {
      key: Order.human_attribute_name(path),
      src: src,
      dest: dest
    })
  end

  def add_order_item_message(src)
    prompt_template(PROMPTS[:ADD_ITEMS], {
      name: src["title"],
      price: src["price"],
      amount: src["amount"]
    })
  end

  def remove_order_item_message(src)
    prompt_template(PROMPTS[:REMOVE_ITEMS], {
      name: src["title"],
      price: src["price"],
      amount: src["amount"]
    })
  end

  def generate_prompt(prompt, key, context)
    prompt_template(prompt, {
      key: OrderItem.human_attribute_name(key),
      src: context[:src],
      dest: context[:dest]
    })
  end

  def prompt_template(template, context)
    template.gsub(/(\$\w+)/) do |name|
      name = name[1..-1].to_sym
      context[name]
    end
  end
end
