class ShopsController < ApplicationController
  before_action :prepare_shop_views_path

  def show_by_name
    @shop = Shop.find_by name: params[:shop_name]

    unless ShopService.valid?(@shop)
      ShopService.build(params[:shop_name])
    end

    @root = @shop.shop_category(true)
    @shop_categories = @root.children.page(params[:page]).per(params[:per])

    render :show
  end

  def show
    @shop = Shop.find params[:id]

    page = params[:page].presence || 1
    per = params[:per].presence || 12

    @shop_categories = @shop.shop_category.children.page(page).per(per)
  end

  private

  def prepare_shop_views_path
    prepend_view_path Settings.sites.shops.root
  end
end
