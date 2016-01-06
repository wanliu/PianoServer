require 'digest/md5'

class OrdersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order, only: [:show, :destroy, :update, :yiyuan_address, :bind_yiyuan_address]
  before_action :check_for_mobile, only: [:index, :show, :history, :confirmation, :buy_now_confirm]
  before_action :set_yiyuan_item_params, only: :yiyuan_confirm
  before_action :set_yiyuan_order_params, only: :create_yiyuan

  include CommonOrdersController

  # caches_action :yiyuan_confirm, layout: false, cache_path: Proc.new do |request|
  #   { etag: Digest::MD5.hexdigest(request.params[:o]) }
  # end

  def yiyuan_confirm
    @order = current_user.orders.build(one_money_id: @one_money_id, pmo_grab_id: @pmo_grab_id)

    @order_item = @order.items.build(@item_params)

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
      if @order.delivery_address.present?
        redirect_to @order
      else
        redirect_to yiyuan_address_order_path(@order)
      end
    else
      render "orders/yiyuan_fail"
    end
  end

  def yiyuan_address
    if @order.delivery_address.blank?
      @location = current_user.locations.build
    else
      redirect_to @order
    end
  end

  def bind_yiyuan_address
    @location = current_user.locations.build(location_params)
    if @location.save
      @order.address_id = @location.id
      @order.save
      redirect_to @order
    else
      render "orders/yiyuan_address"
    end
  end

  private

  def set_yiyuan_item_params
    @item_params = {}

    options = JSON.parse(decode_yiyuan_params(params[:i])).deep_symbolize_keys

    @pmo_grab_id = options[:id]
    @one_money_id = options[:one_money]
    pmo_grab = PmoGrab[@pmo_grab_id]
    if pmo_grab.blank?
      # Todo with invlid parms
    end

    user_id = options[:user_id].to_i

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
      # Todo with invlid parms
    end

    user_id = pmo_grab.user_id.try(:to_i)

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
    params.require(:order).permit(:supplier_id, :pmo_grab_id, :one_money_id)
  end

  def location_params
    params.require(:location)
      .permit(:province_id, :city_id, :region_id, :contact, :id, :road, :zipcode, :contact_phone)
  end
end
