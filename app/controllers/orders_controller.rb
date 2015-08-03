class OrdersController < ApplicationController
  PROMPTS = {
    ALL: '$action了 $key 从 $src 至 $dest',
    ITEMS: '$action了 第 $index 项的 $key 从 $src 至 $dest',
  }

  PROMPT_MATCHS = {
    ALL: '*',
    ITEMS: /items\[(\d+)\]\.(\w+)/
  }

  before_action :set_order_params, only: [:show, :status, :update, :diff ]

  def show
    render json: { order: @order.origin_hash }
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
      new_json    = apply_patch_json @order.update_hash
      pp new_json
      # byebug
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

  def diff
    @diffs = diff_hash @order.origin_hash, @order.update_hash
    render json: { diff: @diffs }
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

  def apply_patch(_json)
    json = _json.dup
    JSON::Patch.new(json, patch_params).call
  end

  def apply_patch_json(json)
    Order.new(apply_patch(json)).origin_hash
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
