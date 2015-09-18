class Shops::Admin::ProfilesController < Shops::Admin::BaseController
  def show
  end

  def update
    @shop.update(shop_profile_params)

    redirect_to shop_admin_profile_path(@shop.name)
  end

  def upload_shop_logo
    @shop.logo = params[:file] || params[:qqfile]

    if @shop.save
      render json: {success: true, url: @shop.logo.url(:cover)}, status: :ok, content_type: "text/html"
    else
      render json: {errors: @shop.errors}, status: :unprocessable_entity, content_type: "text/html"
    end
  end

  protected

    def shop_profile_params
      params.require(:shop).permit(:title, :phone, :website, :description, :address)
    end
end
