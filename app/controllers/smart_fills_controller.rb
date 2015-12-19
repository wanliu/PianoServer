class SmartFillsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_content_for

  def index
    @location = Location.new
  end

  def fast_register
    current_user.user_type = "retail"
    current_user.save(:validate => false)

    shop = current_user.owner_shop || Shop.new(shop_params.merge(owner_id: current_user.id))
    shop.skip_validates = true
    shop.shop_type = 'retail'
    shop.theme = Settings.shop.default_theme
    current_user.create_status(state: :select)

    if Settings.weixin.regions
      shop.build_location location_params.merge(skip_validation: true)
    end

    if shop.save
      render json: {success: true}
    else
      render json: {success: false, errors: shop.errors.full_messages.join(', ') }
    end
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
