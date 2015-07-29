class OrdersController < ApplicationController

  def status
    @order = Order.find(params[:id])
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
      order_json    = Order.find(params[:id]).as_json(include: :items)
      items_json    = order_json["items"]
      patch_params  = params[:patch].map { |k, v| v }
      new_json      = JSON::Patch.new(order_json.deep_dup, patch_params).call

      byebug
      @removed, @added = order_json.easy_diff new_json
      pp @removed, @added
    rescue Exception => ex
      puts ex.message
      puts ex.backtrace.join("\n")
      @@removed = @added = {}
    ensure
      render json: { removed: @removed, added: @added }
    end
  end
end
