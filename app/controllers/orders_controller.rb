class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy]

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all.order(id: :desc).page(params[:page]).per(params[:per])
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = current_user.orders.build(order_params)

    if @order.save_with_cart_items(current_user)
      redirect_to @order
      # render json: @order, status: :created, location: @order
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  # def update
  #   @order = Order.find(params[:id])

  #   if @order.update(order_params)
  #     head :no_content
  #   else
  #     render json: @order.errors, status: :unprocessable_entity
  #   end
  # end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order.destroy

    head :no_content
  end

  private

    def set_order
      @order = current_user.orders.find(params[:id])
    end

    def order_params
      params.require(:order).permit(:supplier_id, :total, :delivery_address, cart_item_ids: [])
    end
end
