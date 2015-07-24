class ShopCategoriesController < ApplicationController
  def index
    @shop_categories = ShopCategory.where(shop_id: params[:shop_id])
  end

  def show
    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @shop_category = ShopCategory.find(params[:id])
    @items = Item.where(shop_category_id: params[:id], page: page, per: per)
  end
end
