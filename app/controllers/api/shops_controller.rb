class Api::ShopsController < Api::BaseController
  before_action :set_shop
  skip_before_action :authenticate_user!

  def favorite_count
    favorites = @shop.favoritables
    count = favorites.count

    render json: { count: count }
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end

end

