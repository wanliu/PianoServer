class Api::ShopsController < Api::BaseController
  before_action :set_shop, only: [:favorite_count]
  skip_before_action :authenticate_user!

  def search
    q = params[:q]
    @shops = Shop.where("title LIKE :title OR name LIKE :name", title: "%#{q}%", name: "%#{q}%").limit(10)

    if params[:except].present?
      @shops = @shops.where.not(id: params[:except])
    end

    render json: @shops.as_json(only: [:id, :name, :title, :logo])
  end

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

