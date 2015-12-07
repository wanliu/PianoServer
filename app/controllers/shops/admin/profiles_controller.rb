class Shops::Admin::ProfilesController < Shops::Admin::BaseController
  include PublicActivity::StoreController

  def show
  end

  def update
    if @shop.update(shop_profile_params)
      if location_change?
        @shop.create_location location_params.merge(skip_validation: true)
        @shop.create_activity action: 'update_location', owner: current_user
      end

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

  def location_change?
    @shop && @shop.location.try(:region_id) != location_params[:region_id].to_i
  end

  protected

  def shop_profile_params
    params.require(:shop).permit(:title, :phone, :website, :description, :address)
  end

  def location_params
    params[:location].permit(:province_id, :city_id, :region_id)
  end
end
