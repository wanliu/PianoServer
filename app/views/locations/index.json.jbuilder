json.array! @locations do |location|
  json.id location.id
  json.address location.address
  json.is_default location.default?
end
