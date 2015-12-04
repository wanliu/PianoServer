class Shops::Admin::BaseController < ApplicationController
  layout "shop_admin"

  before_action :authenticate_user!
  before_action :set_shop
  before_action :shop_page_info
  # before_action :authenticate_shop_user!


  helper_method :current_shop

  def moudle
    "shop"
  end

  private

  def set_shop
    @shop = Shop.find_by name: params[:shop_id], owner_id: current_user.id
    raise ActiveRecord::RecordNotFound if @shop.blank?
    content_for :module, :shop_admin
  end

  def shop_page_info
    self.page_title += [ "设置", t("titles.shops", shop_name: @shop.title) ]
    self.page_navbar = "设置 -#{@shop.title}"
    self.page_navbar_link = shop_admin_index_path(@shop.name)
  end

  # def authenticate_shop_user!
  #   user_id = current_user.try(:id)
  #   raise Errors::Forbidden unless current_user.try(:shop) == @shop or current_user.try(:id) == @shop.owner_id
  # end

  def current_shop
    @shop ||= Shop.find_by name: params[:shop_id], owner_id: current_user.id
  end
end

