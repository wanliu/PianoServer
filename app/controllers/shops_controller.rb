class ShopsController < ApplicationController

  def show_by_name
    @shop = Shop.find_by name: params[:shop_name]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    # @shop_categories = ShopCategory.where(shop_id: @shop.id, page: page, per: per)
    @shop_categories = []
    render :show
  end

  def show
    @shop = Shop.find params[:id]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    # @shop_categories = ShopCategory.where(shop_id: @shop.id, page: page, per: per)
    @shop_categories = []
  end
end
