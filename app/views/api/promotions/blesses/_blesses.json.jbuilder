json.blesses @blesses do |bless|
  json.extract! bless, :message, :id, :created_at, :birthday_party_id
  json.sender bless.sender, :nickname, :login, :avatar_url, :id
  json.virtual_present bless.virtual_present_infor
  json.messages bless.bless_messages.as_json(methods: [:sender_avatar, :sender_username])
end
json.total @total
