json.extract! @location, *@location.attribute_names
json.delivery_address @location.delivery_address
json.province_name @location.province_name
json.city_name @location.city_name
json.region_name @location.region_name
json.zipcode @location.zipcode

if current_user.present?
  json.reach_user_limit current_user.reach_location_limit?
end
