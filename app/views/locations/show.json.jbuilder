json.extract! @location, *@location.attribute_names
json.delivery_address @location.delivery_address
if current_user.present?
  json.reach_user_limit current_user.reach_location_limit?
end