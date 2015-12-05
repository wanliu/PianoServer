class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :update]

  # GET /orders
  # GET /orders.json
  def index
    @orders = current_user.orders
      .initiated
      .includes(:items, :supplier)
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])

  end

  def history
    @orders = current_user.orders
      .finish
      .includes(:items, :supplier)
      .order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = current_user.orders.build(order_params)

    respond_to do |format|
      if @order.save_with_items(current_user)
        format.html { redirect_to @order }
        format.mobile { redirect_to @order }
        format.json { render json: @order, status: :created }
      else
        format.html do
          # if "提交订单" == params[:commit] # 购物车购买
          # elsif "立即购买" # 立即购买
          #   render :buy_now
          # end

          set_feed_back
          flash.now[:error] = @order.errors.full_messages.join(', ')

          render :confirmation, status: :unprocessable_entity
        end
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # 购物车结算
  def confirmation
    @order = current_user.orders.build(order_params)

    set_feed_back

    @order.address_id = @delivery_addresses.first.id if @delivery_addresses.present?
  end

  # 直接购买
  def buy_now_confirm
    @order = current_user.orders.build

    # @cart_item = CartItem.new(order_item_params)
    @order_item = @order.items.build(order_item_params)

    @order.supplier_id = @order_item.orderable.try(:shop_id)
    @order_item.quantity ||= 1
    @order_item.title = @order_item.orderable.title

    sale_mode = current_anonymous_or_user.sale_mode
    @order_item.price =
      case @order_item.orderable
      when Item
        if sale_mode == "retail"
          @order_item.orderable.public_price
        else
          @order_item.orderable.price
        end
      when Promotion
        @order_item.orderable.discount_price
      else
        0
      end

    @delivery_addresses = current_user.locations.order(id: :asc)
    @order.address_id = @delivery_addresses.first.id if @delivery_addresses.present?

    @supplier = @order.supplier 

    @total = @order_item.price * @order_item.quantity

    @props = params[:cart_item][:properties]
  end

  # 直接购买生成订单
  def buy_now_create
    @order = current_user.orders.build(buy_now_order_params)
    
    respond_to do |format|
      if @order.save_with_items(current_user)
        format.html { redirect_to @order }
        format.json { render json: @order, status: :created }
      else
        format.html do
          @order_item = @order.items.first
          @delivery_addresses = current_user.locations.order(id: :asc)
          @supplier = @order.supplier
          @total = @order_item.price * @order_item.quantity

          flash.now[:error] = @order.errors.full_messages.join(', ')

          render :buy_now_confirm, status: :unprocessable_entity
        end
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    respond_to do |format|
      if @order.update(order_update_params)
        format.json { head :no_content }
        format.html { redirect_to history_orders_path }
      else
        format.json { render json: @order.errors, status: :unprocessable_entity }
        format.html { render :show, flash[:now] = @order.errors.full_messages.join(', ') }
      end
    end
  end

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
    params.require(:order).permit(:supplier_id, :address_id, cart_item_ids: [])
  end

  def order_update_params
    params.require(:order).permit(:status)
  end

  def buy_now_order_params
    params.require(:order)
      .permit(:supplier_id, :address_id, items_attributes: [:orderable_type, :orderable_id, :quantity, :price, :title])
      .tap do |white_list|
        white_list[:items_attributes].each do |key, attributes|
          attributes[:properties] = params[:order][:items_attributes][key][:properties] || {}
        end
      end
  end

  def order_item_params
    params.require(:cart_item).permit(:orderable_type, :orderable_id, :quantity, :price).tap do |white_list|
      white_list[:properties] = params[:cart_item][:properties] || {}
    end
  end

  def set_feed_back
    @delivery_addresses = current_user.locations.order(id: :asc)

    @order_items = current_user.cart.items.find(params[:order][:cart_item_ids])

    @supplier = Shop.find(params[:order][:supplier_id])

    @total = @order_items.reduce(0) { |total, item| total += item.price * item.quantity }
  end
end
