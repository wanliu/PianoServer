class ShopsController < ApplicationController
  before_action :prepare_shop_views_path
  before_action :set_shop, only: [ :show_by_name, :show ]
  before_action :shop_page_info

  def show_by_name
    set_page_title @shop.title
    # @title = @shop.title
    page = params[:page].presence || 1
    per = params[:per].presence || 9

    unless ShopService.valid?(@shop)
      ShopService.build(params[:shop_name])
    end

    @root = @shop.shop_category(true)
    @shop_categories = @root.children.page(page).per(per)

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

  def set_shop
    @shop = Shop.find_by name: params[:shop_name]
  end

  def shop_page_info
    self.page_title += [ t("titles.shops", shop_name: @shop.title) ]
    self.page_navbar = @shop.title
    self.page_navbar_link = shop_site_path(@shop.name)
  end
end
