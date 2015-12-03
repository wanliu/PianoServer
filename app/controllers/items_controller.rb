class ItemsController < ApplicationController
  before_filter :set_shop
  before_filter :set_item, only: [ :show ]

  # caches_page :index, :show

  def index
    page = params[:page].presence || 1
    per = params[:per].presence || 8

  	@items = if params[:shop_id].present?
      Item.where(shop_id: params[:shop_id]).page(page).per(per)
  	elsif params[:shop_category_id].present?
      Item.where(shop_category_id: params[:shop_category_id]).page(page).per(per)
  	else
      []
    end

  end

  def show
    @item.punch(request)
    @category = @item.category
    @current_user = current_anonymous_or_user

    @cartitem = CartItem.new(cartable: @item, supplier: @shop, title: @item.title, image: @item.image.url(:cover))
  
    if Settings.dev.feature.inventory_combination and @item.properties.present?
      @stocks_with_index = @item.stocks_with_index
    end

    render :show, with: @item.category
  end

  private

  def set_shop
    @shop = Shop.find_by(name: params[:shop_id])
    @shop.punch(request)
  end

  def set_item
    @item = @shop.items.find_by_key(params)
  end

  def normal_properties(properties)
    properties.reject { |prop|  prop.prop_type == "stock_map" }
  end

  def inventory_properties(properties)
    properties.select { |prop| prop.prop_type == "stock_map" }
  end
end
