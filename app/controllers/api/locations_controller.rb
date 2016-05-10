class Api::LocationsController < Api::BaseController
  skip_before_action :authenticate_user!

  def provinces
    provinces = ChinaCity.list

    render json: provinces
  end

  def cities
    cities = ChinaCity.list params[:province_id].to_s

    render json: cities
  end

  def regions
    regions = ChinaCity.list params[:city_id].to_s

    render json: regions
  end
end
