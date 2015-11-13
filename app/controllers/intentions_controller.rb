class IntentionsController < ApplicationController
  PROMPTS = {
    ALL: '$key从 $src 变更为 $dest ',
    ADD_ITEMS: '添加 $name ，价格： $price ，数量： $amount ',
    REMOVE_ITEMS: '移除 $name ，价格： $price ，数量： $amount '
  }

  PROMPT_MATCHS = {
    ALL: '*',
    ITEMS: /items\[(\d+)\]\.(\w+)/
  }

  class IntentionInvalidState < StandardError; end

  before_action :set_intention_params,
    only: [:show, :status, :update, :diff, :accept, :ensure,
            :cancel, :reject, :items, :add_item, :set_address]

  def show
    # if params[:inline]
    #   render json: { intention: @intention, html: :partial => "intention" }
    # else
    #   render json: { intention: @intention.origin_hash }
    # end
  end

  def status
    response = {
      state: @intention.state
    }

    response.merge!(url: @intention.avatar_url) if @intention.state == :done or @intention.state == "done"

    respond_to do |format|
      format.json do
        render json: response
      end
    end
  end

  def update
    begin
      # 应用修改记录， 返回一个新的 json
      new_json    = @intention.apply_patch(patch_params)

      # 用差分算法比较两个同的 hash, 返回 diff 数组
      @diffs = diff_hash @intention.update_hash, new_json
      unless @diffs.blank?
        @intention.updates = new_json
        @intention.save
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
    old_address = @intention.delivery_address_title

    delivery_address = params[:delivery_address]

    if delivery_address[:location_id].to_i > 0
      @intention.delivery_location_id = delivery_address[:location_id]
    else
      @intention[:data] ||= {}
      @intention[:data]["delivery_address"] = delivery_address
    end

    @intention.save

    new_address = @intention.delivery_address_title

    msg = modify_intention('delivery_address', old_address, new_address)

    MessageSystemService.push_message current_anonymous_or_user.id, other_side, msg, to: [other_side], type: 'order'
    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order-address', dest: new_address}.to_json

    # render json: @intention.delivery_location
    head :ok
  end

  def diff
    @diffs = diff_hash @intention.origin_hash, @intention.update_hash
    render json: { diff: @diffs }
  end

  def accept
    if @intention.accept_state != "accepting"
      @intention.update(:accept_state => "accepting")
      MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'accepting'}.to_json
    else
      throw IntentionInvalidState.new("invalid accept_state #{@intention.accept_state} in accepting")
    end
    render json: { accept_state: @intention.accept_state }
  end

  def ensure
    update_hash = @intention.update_hash
    if @intention.accept_state == 'accepting'
      update_hash["accept_state"] = "accept"
      @intention.update(accept_state: "accept")
      @intention.update_patch(update_hash)
      # @intention.items_attributes = update_hash["items"]
      # @intention.save

      MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'accept'}.to_json
    else
      throw IntentionInvalidState.new 'This accepting intention job is cancel.'
    end

    params[:inline] = true
    render :show, formats: [:json]

    # render json: { accept_state: @intention.accept_state }
  end

  def cancel
    @intention.update(:accept_state => "cancel")
    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'cancel'}.to_json
    render json: { accept_state: @intention.accept_state }
  end

  def reject
    @intention.update(:accept_state => "reject")
    @intention.update(updates: nil)
    msg = '拒绝了提交的修改'

    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'reject'}.to_json

    MessageSystemService.push_message current_anonymous_or_user.id, other_side, msg, to: [other_side], type: 'order'

    render :show, formats: [:json]
  end

  def items
    # @intention.supplier.
    @items = []
  end

  def add_item
  end

  private

  # 获取 intention 对象
  def set_intention_params
    @intention = Intention.find(params[:id])
  end

  #将 params 数字为 key 的 hash 转换成 Array
  def patch_params
    params[:patch] # .map { |k, v| v }
  end

  def diff_hash(one, two)
    HashDiff.best_diff one, two
  end

  def other_side
    if @intention.buyer_id == current_anonymous_or_user.id
      @intention.seller_id || @intention.supplier.owner_id
    else
      @intention.buyer_id
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
          when '+' then add_intention_item_message(src)
          when '~' then update_intention_message(diff_items, path, src, dest)
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

  def update_intention_message(diff_items, path, src, dest)
    if path =~ PROMPT_MATCHS[:ITEMS]
      modify_intention_items(diff_items, path, src, dest)
    else
      modify_intention(path, src, dest)
    end
  end

  def modify_intention_items(diff_items, path, src, dest)
    m = path.match(PROMPT_MATCHS[:ITEMS])
    index, key = m[1].to_i, m[2]
    intention_item = @intention.items[index]

    if key == "deleted" && src == false && dest == true
      return remove_intention_item_message(intention_item)
    end

    diff_item = diff_items[index] ||= {}
    diff_item[:name] = intention_item.title

    item = diff_item[key] ||= {}

    item[:src] = src if item[:src].blank?
    item[:dest] = dest

    nil
    # name, key = @intention.items[index].title, LineItem.human_attribute_name(m[2])
    # prompt = PROMPTS[:ITEMS]
  end

  def modify_intention(path, src, dest)
    prompt_template(PROMPTS[:ALL], {
      key: Intention.human_attribute_name(path),
      src: src,
      dest: dest
    })
  end

  def add_intention_item_message(src)
    prompt_template(PROMPTS[:ADD_ITEMS], {
      name: src["title"],
      price: src["price"],
      amount: src["amount"]
    })
  end

  def remove_intention_item_message(src)
    prompt_template(PROMPTS[:REMOVE_ITEMS], {
      name: src["title"],
      price: src["price"],
      amount: src["amount"]
    })
  end

  def generate_prompt(prompt, key, context)
    prompt_template(prompt, {
      key: LineItem.human_attribute_name(key),
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
