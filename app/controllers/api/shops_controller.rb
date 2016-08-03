class Api::ShopsController < Api::BaseController
  before_action :set_shop
  skip_before_action :authenticate_user!

  def show
    location = @shop.try(:location).try(:delivery_address_without_phone)
    hash = @shop.as_json(only: [ :name, :title, :id ], methods: [:avatar_url])
    hash['location'] = location

    render json: hash
  end

  def favorite_count
    favorites = @shop.favorites
    count = favorites.count

    render json: { count: count }
  end

  private

  def set_shop
    @shop = Shop.find(params[:id])
  end
end

