class ShopCategoriesController < ApplicationController
  def index
    @shop_categories = ShopCategory.where(shop_id: params[:shop_id])
  end

  def show
    @shop_category = ShopCategory.find(params[:id])
    @items = Item.where(shop_category_id: params[:id])
  end
end
