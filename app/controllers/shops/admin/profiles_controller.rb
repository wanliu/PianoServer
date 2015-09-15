class Shops::Admin::ProfilesController < Shops::Admin::BaseController
  def show
  end

  def update
    @shop.update(shop_profile_params)

    redirect_to shop_admin_profile_path(@shop.name)
  end

  def upload_shop_logo
    @shop = Shop.find(params[:shop_id])
    @shop.logo = params[:file]

    if @shop.save
      render json: {success: true, url: @shop.logo.url(:cover)}, status: :ok
    else
      render json: {errors: @shop.errors}, status: :unprocessable_entity
    end
  end

  protected

    def shop_profile_params
      params.require(:shop).permit(:title, :phone, :website, :description)
    end
end
