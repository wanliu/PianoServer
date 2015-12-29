class SmartFillsController < ApplicationController
  include RedirectCallback

  before_action :authenticate_user!
  before_action :set_content_for

  def index
    @location = Location.new
  end

  def fast_register
    current_user.user_type = "retail"
    current_user.mobile = params[:shop][:phone]

    begin
      current_user.save(:validate => false)
    rescue ActiveRecord::RecordNotUnique => e
      render json: {success: false, errors: ['联系电话已被人使用'] }
      return
    end

    shop = current_user.owner_shop || Shop.new(shop_params.merge(owner_id: current_user.id))
    shop.send(:default_values)
    shop.skip_validates = true
    shop.shop_type = 'retail'
    shop.theme = Settings.shop.default_theme

    if Settings.weixin.regions
      shop.build_location location_params.merge(skip_validation: true)
    end

    if shop.save
      shop.reload

      current_user.create_status(state: :shop)

      if request.xhr?
        render json: {success: true, callback_url: callback_url }
      else
        redirect_to callback_url
      end

      clear_callback
    else
      render json: {success: false, errors: shop.errors.full_messages }
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
