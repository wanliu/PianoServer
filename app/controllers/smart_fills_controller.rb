class SmartFillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_for

  def index
    # redirect_to smart_fills_path(current_user.user_type) unless current_user.state.nil?
  end

  def show

  end

  def fast_register
    current_user.user_type = "retail"
    current_user.save(:validate => false)

    shop = current_user.owner_shop || Shop.new(shop_params.merge(owner_id: current_user.id))
    shop.shop_type = 'retail'
    shop.theme = Settings.shop.default_theme
    shop.create_status(state: "select")

    shop.save(:validate => false)

    @notice = '恭喜您快速开店成功'

    redirect_to root_path
  end

  private
  def set_content_for
    content_for :module, :smart_fills
  end

  def shop_params
    params.require(:shop).permit(:title, :phone)
  end

  def location_params
    params[:location].permit(:province_id, :city_id, :region_id)
  end
end
