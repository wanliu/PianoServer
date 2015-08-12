class OrdersController < ApplicationController
  PROMPTS = {
    ALL: '$action了 $key 从 $src 至 $dest',
    ITEMS: '$action了 第 $index 项的 $key 从 $src 至 $dest',
  }

  PROMPT_MATCHS = {
    ALL: '*',
    ITEMS: /items\[(\d+)\]\.(\w+)/
  }

  class OrderInvalidState < StandardError; end

  before_action :set_order_params,
    only: [:show, :status, :update, :diff, :accept, :ensure,
            :cancel, :reject, :items, :add_item, :default_address]

  def show
    # if params[:inline]
    #   render json: { order: @order, html: :partial => "order"
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

  def default_address
    @order = Order.find(params[:order_id])
    if params[:default_location_id].to_i > 0
      @order.delivery_location_id = params[:default_location_id]
      @order.save
    else
      @order.create_delivery_location(params.require(:address).permit(:id,:contact,:zipcode,:contact_phone,:province_id,:city_id,:region_id))
    end
    render json: @order.delivery_location
    # head :ok
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
    MessageSystemService.push_command current_anonymous_or_user.id, other_side, {command: 'order', accept: 'reject'}.to_json

    render :show, formats: [:json]
  end

  def items
    # @order.supplier.
    []
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

    diffs.each do |op, path, src, dest|
      if path =~ PROMPT_MATCHS[:ITEMS]
        m = path.match(PROMPT_MATCHS[:ITEMS])
        index, key = m[1].to_i + 1, m[2]
        prompt = PROMPTS[:ITEMS]
      else
        prompt = PROMPTS[:ALL]
        index = nil
        key = path
      end

      action = case op
               when '+' then '增加'
               when '-' then '删除'
               when '~' then '修改'
               end

      msg = prompt_template(prompt, {
        action: action,
        author: current_anonymous_or_user.name,
        key: key,
        src: src,
        index: index,
        dest: dest
      })
      MessageSystemService.push_message user_id, other_side, msg, to: [other_side], type: 'order', key: path
    end
    MessageSystemService.push_command user_id, other_side, {command: 'order', diff: diffs}.to_json
  end

  def prompt_template(template, context)
    template.gsub(/(\$\w+)/) do |name|
      name = name[1..-1].to_sym
      context[name]
    end
  end
end
