json.blesses @blesses do |bless|
  json.extract! bless, :message, :id, :created_at
  json.sender bless.sender, :login, :avatar_url, :id
  json.virtual_present bless.virtual_present, :id, :name
end
json.total @total
