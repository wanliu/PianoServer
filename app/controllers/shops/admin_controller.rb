class Shops::AdminController < Shops::Admin::BaseController

  def upload_shop_logo
    @shop = Shop.find(params[:shop_id])
    @shop.logo = params[:file]

    if @shop.save
      render json: {success: true, url: @shop.logo.url(:cover)}, status: :ok
    else
      render json: {errors: @shop.errors}, status: :unprocessable_entity
    end
  end
end
