class Shops::AdminController < Shops::Admin::BaseController

  # def
  # def profile
  # end
  def update_shop_profile
    @shop.update(shop_profile_params)

    redirect_to shop_admin_profile_path(@shop.name)
  end

  protected

  def shop_profile_params
    params.require(:shop).permit(:title, :phone, :website, :description)
  end
end
