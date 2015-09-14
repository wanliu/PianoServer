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

  def index
    redirect_to shop_admin_dashboard_index_path(@shop.name)
  end

  def update_shop_profile
    @shop.update(shop_profile_params)

    redirect_to shop_admin_profile_path(@shop.name)
  end

  protected

  def shop_profile_params
    params.require(:shop).permit(:title, :phone, :website, :description)
  end
end
