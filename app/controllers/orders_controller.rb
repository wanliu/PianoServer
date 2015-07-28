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
end
