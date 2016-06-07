require 'weixin_api'

class OrdersController < ApplicationController
  before_action :authenticate_user!

  before_action :set_order,
    only: [
      :show,
      :destroy,
      :update,
      :set_wx_pay,
      :pay_kind,
      :wxpay,
      :wxpay_confirm,
      :wx_paid,
      :receive,
      :qrcode_receive
    ]

  before_action :set_evaluatable_order,
    only: [
      :evaluate,
      :evaluate_item,
      :create_evaluations,
      :evaluate_item_create
    ]

  before_action :check_for_mobile,
    only: [
      :index,
      :show,
      :history,
      :confirmation,
      :buy_now_confirm,
      :buy_now_create,
      :evaluate,
      :evaluate_item,
      :create_evaluations,
      :evaluate_item_create, 
      :receive, 
      :qrcode_receive,
      :express_fee
    ]

  before_action :set_order_item, only: [:evaluate_item, :evaluate_item_create]
  skip_before_filter :verify_authenticity_token, :only => [:buy_now_confirm]

  include ParamsCallback
  include YiyuanOrdersController
  include WxpayController

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
    if @order.pmo_grab_id.present?
      pmo_grab = PmoGrab[@order.pmo_grab_id]
      pmo_item = PmoItem[pmo_grab.pmo_item_id]

      one_money = OneMoney[@order.one_money_id]
      @one_more_time = pmo_grab.seeds.any? { |seed| "pending" == seed.status }
      redirect_url = one_money.try(:publish_url) || "/one_money/#{ one_money.start_at.strftime('%Y-%m-%d') }/index.html"
      @redirect_url = "#{redirect_url}#/detail/#{ pmo_grab.pmo_item_id }"
    end
    # @order.items.includes(:orderable)
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = current_user.orders.build(order_params)

    respond_to do |format|
      if @order.save_with_items(current_user)
        format.json { render json: @order, status: :created }
        format.html { redirect_to @order }
      else
        format.html do
          set_feed_back
          set_addresses_add_express_fee
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

    set_addresses_add_express_fee
  end

  def select_coupon
    @order = current_user.orders.build(order_params)
    
    render_coupons
  end

  def buy_now_select_coupon
    @order = current_user.orders.build(buy_now_order_params)
    @order.items.each(&:set_initial_attributes)

    render_coupons
  end

  # 直接购买
  def buy_now_confirm
    @order = current_user.orders.build

    @order_item = @order.items.build(order_item_params)

    @order.supplier_id = @order_item.orderable.try(:shop_id)

    @order_item.set_initial_attributes

    @orderable = @order_item.orderable
    if @orderable.is_a? Item
      @orderable.eval_available_gifts(@order_item.quantity)
    end

    set_addresses_add_express_fee

    @supplier = @order.supplier

    @total = @order_item.price * @order_item.quantity

    @props = params[:cart_item][:properties]
  end

  # 直接购买生成订单
  def buy_now_create
    @order = current_user.orders.build(buy_now_order_params)

    @order.items.each(&:set_initial_attributes)

    respond_to do |format|
      if @order.save_with_items(current_user)
        format.html { redirect_to @order }
        format.mobile { redirect_to @order }
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
        format.html do
          # 一元购收货后跳到评价页面
          if @order.wait_for_yiyuan_evaluate?
            one_money = OneMoney[@order.one_money_id]
            redirect_url = one_money.try(:publish_url) || "/one_money/#{ one_money.start_at.strftime('%Y-%m-%d') }/index.html"
            redirect_to "#{redirect_url}#/comment/#{ @order.pmo_grab_id }/#{@order.id}"
          elsif @order.wait_for_evaluate?
            redirect_to evaluate_order_path(@order)
          else
            redirect_to history_orders_path
          end
        end
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

  # 用户切换收货地址时，计算新地址的运送费用
  def express_fee
    @order = current_user.orders.build(express_fee_params)
    @order.set_express_fee

    @order.items.each do |item|
      item.price = item.caculate_price
    end

    @coupons_avaliable = @order.coupons_available?

    # if params[:order][:items_attributes].present?
    #   render partial: "buy_now_confirmation_total"
    # else
      render partial: "confirmation_total"
    # end
  end

  # 批量评价
  def evaluate
    @evaluations = @order.evaluations_list_with_build
  end

  # 单个商品评价（手机端）
  def evaluate_item
    @evaluation = @order.evaluations.find_by(
      evaluationable_type: @item.orderable_type,
      evaluationable_id: @item.orderable_id)

    unless @evaluation.present?
      @evaluation = @order.evaluations.build
    end
  end

  # 批量评价
  def create_evaluations
    if @order.update(evaluation_params)
      redirect_to evaluate_order_path(@order)
    else
      flash.alert = @order.errors.full_messages.join(', ')
      @evaluations = @order.evaluations_list_with_build
      render :evaluate
    end
  end

  # 单个商品评价（手机端）
  def evaluate_item_create
    @evaluation = @order.evaluations.build(item_evaluation_params)

    if @evaluation.save
      redirect_to evaluate_order_path(@order)
    else
      flash.alert = @evaluation.errors.full_messages.join(', ')
      render :evaluate_item
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def set_order_item
    @item = @order.items.find(params[:order_item_id])
  end

  def set_evaluatable_order
    @order = current_user.orders
      .includes(:items)
      .find(params[:id])

    unless @order.evaluatable?
      flash.alert = "订单未完成，无法评价"
      redirect_to order_path(@order)
    end
  end

  def order_update_params
    params.require(:order).permit(:status, :note)
  end

  def buy_now_order_params
    params.require(:order)
      .permit(:supplier_id,
        :address_id, 
        :note, 
        items_attributes: [:orderable_type, :orderable_id, :quantity],
        coupon_ids: [])
      .tap do |white_list|
        white_list[:items_attributes].each do |key, attributes|
          attributes[:properties] = params[:order][:items_attributes][key][:properties] || {}
        end

        if params[:order][:item_gifts].present?
          white_list[:item_gifts] = params[:order][:item_gifts]
        end
      end
  end

  def order_item_params
    params.require(:cart_item).permit(:orderable_type, :orderable_id, :quantity, :price).tap do |white_list|
      white_list[:properties] = params[:cart_item][:properties] || {}
    end
  end

  def set_feed_back
    @order_items = current_user.cart.items.find(@order.cart_item_ids || [])

    @supplier = Shop.find(params[:order][:supplier_id])

    @total = @order_items.reduce(0) { |total, item| total += item.price * item.quantity }
  end

  def set_addresses_add_express_fee
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

    @order.set_express_fee
  end

  def order_params
    params.require(:order)
      .permit(:supplier_id, 
        :address_id, 
        :pmo_grab_id, 
        :one_money_id,
        :note,
        coupon_ids: []).tap do |white_list|
      if params[:order][:cart_item_ids].present?
        white_list[:cart_item_ids] = params[:order][:cart_item_ids]
      end

      if params[:order][:cart_item_gifts].present?
        white_list[:cart_item_gifts] = params[:order][:cart_item_gifts]
      end
    end
  end

  def express_fee_params
    order_params.tap do |white_list|
      if params[:order][:items_attributes].present?
        white_list[:items_attributes] = params[:order][:items_attributes]
      end
    end
  end

  def location_params
    params.require(:location)
      .permit(:province_id, :city_id, :region_id, :contact, :id, :road, :zipcode, :contact_phone)
  end

  # 过滤空的未填写的评价，并且设置user_id
  def evaluation_params
    params.require(:order).permit(evaluations_attributes: [
      :desc,
      :good,
      :delivery,
      :evaluationable_id,
      :evaluationable_type,
      :customer_service
    ]).tap do |white_list|
      white_list[:evaluations_attributes].each do |key, value|
        if value[:good].blank? &&
           value[:delivery].blank? &&
           value[:customer_service].blank?

          white_list[:evaluations_attributes].delete(key)
        else
          value["user_id"] = current_user.id
        end
      end
    end
  end

  def item_evaluation_params
    params.require(:evaluation)
      .permit(:good, :delivery, :customer_service, :desc)
      .tap do |white_list|
        white_list[:evaluationable_type] = @item.orderable_type
        white_list[:evaluationable_id] = @item.orderable_id
        white_list[:user_id] = current_user.id
      end
  end

  def render_coupons
    coupons = @order.coupons
    avaliables = @order.available_coupons(coupon_ids: @order.coupon_ids)

    @coupons_avaliable = @order.coupons_available?

    serialize_options = {
      only: [:id, :start_time, :end_time], 
      methods: [:name, :par, :apply_minimal_total, :overlap]
    }

    total_html = render_to_string partial: "/orders/confirmation_total"

    render json: {
      coupons: coupons.as_json(serialize_options),
      avaliable: avaliables.as_json(serialize_options),
      total_html: total_html
    }
  end
end
