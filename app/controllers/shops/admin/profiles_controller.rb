class Shops::Admin::ProfilesController < Shops::Admin::BaseController
  def show
  end

  def update
    if @shop.update(shop_profile_params)
      expire_page shop_site_path(@shop.name)
      redirect_to shop_admin_profile_path(@shop.name)
    else
      flash.now[:error] = @shop.errors.full_messages.join(', ')
      render :show, status: :unprocessable_entity
    end
  end

  def upload_shop_logo
    @shop.update_attribute("logo", params[:file] || params[:qqfile])
    expire_page shop_site_path(@shop.name)
    render json: {success: true, url: @shop.logo.url(:cover)}, status: :ok, content_type: "text/html"
  end

  protected

    def shop_profile_params
      params.require(:shop).permit(:title, :phone, :website, :description, :address)
    end
end
