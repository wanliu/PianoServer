class ShopsController < ApplicationController

  def show_by_name
    @shop = Shop.find_by name: params[:shop_name]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @categories = @shop.categories.page(page).per(per)
    render :show
  end

  def show
    @shop = Shop.find params[:id]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @categories = @shop.categories.page(page).per(per)
  end
end
