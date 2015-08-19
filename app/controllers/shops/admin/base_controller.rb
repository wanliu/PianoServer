class Shops::Admin::BaseController < ApplicationController
  layout "shop_admin"

  before_action :set_shop


  def set_shop
    @shop = Shop.find_by name: params[:shop_id]
  end
end
