class ShopCategoriesController < ApplicationController
  before_filter :set_shop
  before_filter :set_shop_category, only: [ :show ]

  def index
    @shop_categories = @shop.categories.page(page).per(per)
  end

  def show
    page = params[:page].presence || 1

    if @shop_category.has_children
      per = params[:per].presence || 9
      @shop_categories = Category.where(parent_id: @shop_category).page(page).per(per)
      @items = []
    else
      per = params[:per].presence || 8
      @items = Item.where(shop_category_id: params[:id]).page(page).per(per)
      @shop_categories = []
    end
  end

  private
    def set_shop
      @shop = Shop.find_by(name: params[:shop_id])
    end

    def set_shop_category    
      @shop_category = @shop.categories.find(params[:id])
    end
end
