class ShopsController < ApplicationController
  before_action :prepare_shop_views_path

  def show_by_name
    @shop = Shop.find_by name: params[:shop_name]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    unless ShopService.valid?(@shop)
      ShopService.build(params[:shop_name])
    end

    @root = @shop.categories.find_by(name: 'product_category')
    @categories = @root.children.page(page).per(per)

    render :show
  end

  def show
    @shop = Shop.find params[:id]

    page = params[:page].presence || 1
    per = params[:per].presence || 9

    @categories = @shop.categories.page(page).per(per)
  end

  private

  def prepare_shop_views_path
    prepend_view_path Settings.sites.shops.root
  end
end
