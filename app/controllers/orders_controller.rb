class OrdersController < ApplicationController
  before_action :set_order_params, only: [:status, :update, :diff ]

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
      @diffs = diff_hash @order.origin_hash, new_json
      unless @diffs.blank?
        @order.updates = new_json
        @order.save
      end
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace.join("\n")
      @diffs = []
    ensure
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

end
