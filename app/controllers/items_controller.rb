class ItemsController < ApplicationController
  before_filter :set_shop
  before_filter :set_item, only: [ :show ]

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
    @properties = normal_properties(@category.with_upper_properties)
    @inventory_properties = inventory_properties(@category.with_upper_properties)

    # if Settings.dev.feature.inventory_combination and @inventory_properties.present?
    #   @inventory_combination = combination_properties(@item, @inventory_properties)
    #   @stocks_with_index = {}
    # end

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
