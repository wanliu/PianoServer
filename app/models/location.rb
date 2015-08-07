class Location < ActiveRecord::Base

  def full_address
    city_name(province_id) + city_name(city_id) + city_name(region_id)
  end

  private
  def city_name(city_id)
    ChinaCity.get(city_id)
  end
end
