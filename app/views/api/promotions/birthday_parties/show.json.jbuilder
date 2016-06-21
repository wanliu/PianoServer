json.extract! @birthday_party, *@birthday_party.attribute_names
json.blesses @blesses do |bless|
  json.extract! bless, :message
  json.sender bless.sender, :login, :avatar_url, :id
  json.virtual_present bless.virtual_present, :id, :name
end