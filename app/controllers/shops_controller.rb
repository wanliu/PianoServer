class ShopsController < ApplicationController

  def show_by_name
    @shop = Shop.find(params: { name: params[:shop_name]})

  end

  def show
    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @shop = Shop.find(params[:id])
    @shop_categories = ShopCategory.where(shop_id: @shop.id, page: page, per: per)
  end
end
