class Shops::Admin::BaseController < ApplicationController
  layout "shop_admin"

  before_action :set_shop
  before_action :shop_page_title

  def set_shop
    @shop = Shop.find_by name: params[:shop_id]
  end

  def moudle
    "shop"
  end

  def shop_page_title
    self.page_title += [ t("shops.page_title", shop_name: @shop.title) ]
    pp self.page_title
  end
end

