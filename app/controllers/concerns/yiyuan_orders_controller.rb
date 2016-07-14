module YiyuanOrdersController
  def self.included(mod)
    mod.class_eval do
      before_action :set_yiyuan_item_params, only: :yiyuan_confirm
      before_action :set_yiyuan_order_params, only: :create_yiyuan
    end
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
      # redirect_to pay_kind_order_path(@order)
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

    respond_to do |format|
      if @location.save
        format.html do
          redirect_url = if callback_url.include?('?')
            callback_url.split('&address_id=').first + "&address_id=#{@location.id}"
          else
            callback_url + "?address_id=#{@location.id}"
          end
          redirect_to redirect_url
        end
        format.js
      else
        format.html { render "orders/new_yiyuan_address" }
        format.js
      end
    end
  end

  def pay_kind
  end

  # def set_pay_kind
  #   if "wx_pay" == params[:order][:pay_kind]
  #     @order.request_ip = request.ip
  #     if @order.create_wx_order
  #       redirect_to wxpay_test_orders_path(oid: @order.id)
  #     else
  #       flash[:error] = " 请求微信支付失败，请稍后再试！"
  #       redirect_to pay_kind_order_path(@order)
  #     end
  #   else
  #     redirect_to @order
  #   end
  # end

  private

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
end