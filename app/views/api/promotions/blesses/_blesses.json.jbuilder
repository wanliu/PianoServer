json.blesses @blesses do |bless|
  json.extract! bless, :message, :id, :created_at
  json.sender bless.sender, :nickname, :login, :avatar_url, :id
  json.virtual_present bless.virtual_present_infor
end
json.total @total
