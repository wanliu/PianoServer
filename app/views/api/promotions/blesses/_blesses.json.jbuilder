json.blesses @blesses do |bless|
  json.extract! bless, :message
  json.sender bless.sender, :login, :avatar_url, :id
  json.virtual_present bless.virtual_present, :id, :name
end
json.blesses_page @blesses_page
json.blesses_total_page @blesses_total_page
