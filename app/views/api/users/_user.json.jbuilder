json.(user, :id, :nickname)

if @json_options[:user] == :simple || @json_options[:user] == :detial
  json.username user.username
  json.email user.email
  json.mobile user.mobile
  json.live_token user.live_token
  json.image user.image || { avatar_url: avatar_url(user) }
end

if @json_options[:user] == :detial
  json.created_at user.created_at
  json.updated_at user.udpated_at
end

json.authentication_token user.authentication_token unless @enabled_token.nil?



