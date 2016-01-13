require 'digest/md5'

class OrdersController < ApplicationController
  include ParamsCallback

  before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :update]
  before_action :check_for_mobile, only: [:index, :show, :history, :confirmation, :buy_now_confirm]
  before_action :set_yiyuan_item_params, only: :yiyuan_confirm
  before_action :set_yiyuan_order_params, only: :create_yiyuan

  # caches_action :yiyuan_confirm, layout: false, cache_path: Proc.new do |request|
  #   { etag: Digest::MD5.hexdigest(request.params[:o]) }
  # end

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
        format.any(:html, :mobile) do
          set_feed_back
          set_addresses
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

    set_addresses
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

    set_addresses

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
        format.mobile { redirect_to @order }
        format.json { render json: @order, status: :created }
      else
        format.any(:html, :mobile) do
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

  def yiyuan_confirm
    if params[:address_id].present?
      @location = current_user.locations.find(params[:address_id])
    elsif current_user.locations.present?
      # redirect_to chose_yiyuan_address_orders_path(callback: request.fullpath)
      @location = current_user.latest_location || current_user.locations.last
    else
      redirect_to new_yiyuan_address_orders_path(callback: request.fullpath)
      return
    end

    @order = current_user.orders.build one_money_id: @one_money_id, pmo_grab_id: @pmo_grab_id, address_id: @location.id

    @order_item = @order.items.build(@item_params)
    @order.express_fee = @order.get_pmo_express_fee

    @order.supplier_id = @order_item.orderable.try(:shop_id)
    @order_item.title = @order_item.orderable.title

    @supplier = @order.supplier
    @total = @order_item.orderable_id * @order_item.quantity
    @props = @order_item.properties
  end

  def create_yiyuan
    @order = current_user.orders.build order_params
    @order_item = @order.items.build(@item_params)

    if @order.save_with_pmo(current_user)
      redirect_to @order
    else
      render "orders/yiyuan/fail", status: :unprocessable_entity
    end
  end

  def new_yiyuan_address
    @location = current_user.locations.build
  end

  def chose_yiyuan_address
    @locations = current_user.locations
  end

  def bind_yiyuan_address
    @location = current_user.locations.build(location_params)
    @location.skip_limit_validation = true

    if @location.save
      redirect_to callback_url.split('&address_id=').first + "&address_id=#{@location.id}"
    else
      render "orders/new_yiyuan_address"
    end
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
    @order_items = current_user.cart.items.find(params[:order][:cart_item_ids] || [])

    @supplier = Shop.find(params[:order][:supplier_id])

    @total = @order_items.reduce(0) { |total, item| total += item.price * item.quantity }
  end

  def set_addresses
    shop_address = current_user.owner_shop.try(:location)
    @delivery_addresses = [shop_address].concat current_user.locations.order(id: :asc)
    @delivery_addresses.compact!

    @order.address_id =
      if current_user.latest_location_id.present?
        current_user.latest_location_id
      elsif shop_address.present?
        shop_address.id
      elsif @delivery_addresses.present?
        @delivery_addresses.first.id
      end
  end

  def set_yiyuan_item_params
    @item_params = {}

    options = JSON.parse(decode_yiyuan_params(params[:i])).deep_symbolize_keys

    if current_user.orders.exists?(pmo_grab_id: options[:id])
      render "orders/yiyuan/bought", status: :unprocessable_entity
      return
    end

    @pmo_grab_id = options[:id]
    @one_money_id = options[:one_money]
    pmo_grab = PmoGrab[@pmo_grab_id]
    one_money = OneMoney[@one_money_id]
    if pmo_grab.blank? || one_money.blank?
      render "orders/yiyuan/timeout", status: :unprocessable_entity
      return
    end

    user_id = options[:user_user_id].to_i

    unless user_id == current_user.id
      raise ActiveResource::ResourceNotFound, "not found"
    end

    set_params_from_pmo(pmo_grab)
    @item_params
  end

  def set_yiyuan_order_params
    @item_params = {}

    pmo_grab_id = params[:order][:pmo_grab_id]

    pmo_grab = PmoGrab[pmo_grab_id]
    if pmo_grab.blank?
      render "orders/yiyuan/timeout", status: :unprocessable_entity
      return
    end

    user_id = pmo_grab.user_user_id.try(:to_i)

    unless user_id == current_user.id
      raise ActiveResource::ResourceNotFound, "not found"
    end

    set_params_from_pmo(pmo_grab)

    @item_params
  end

  def set_params_from_pmo(pmo_grab)
    @item_params[:orderable_type] = 'Item'
    @item_params[:orderable_id] = pmo_grab.shop_item_id
    @item_params[:price] = pmo_grab.price
    @item_params[:quantity] = pmo_grab.quantity
    @item_params[:title] = pmo_grab.title
    @item_params[:properties] = {}
  end

  def decode_yiyuan_params(source)
    PmoGrab.encryptor.decrypt(source)
  end

  def order_params
    params.require(:order).permit(:supplier_id, :pmo_grab_id, :one_money_id, :address_id)
  end

  def location_params
    params.require(:location)
      .permit(:province_id, :city_id, :region_id, :contact, :id, :road, :zipcode, :contact_phone)
  end
end
