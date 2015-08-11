class ShopCategoriesController < ApplicationController
  def index
    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @shop_categories = ShopCategory.where(shop_id: params[:shop_id], page: page, per: per)
  end

  def show
    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @shop_category = ShopCategory.find(params[:id])
    @shop = Shop.find(@shop_category.shop_id)

    if @shop_category.has_children
      @shop_categories = ShopCategory.where(parent_id: @shop_category, page: page, per: per)
      @items = []
    else
      @items = Item.where(shop_category_id: params[:id], page: page, per: 8)
      @shop_categories = []
    end
  end
end
