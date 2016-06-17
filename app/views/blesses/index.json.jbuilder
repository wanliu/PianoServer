json.array!(@blesses) do |bless|
  json.extract! bless, :id, :sender_id, :virtual_present_id, :message, :birthday_party_id
  json.url bless_url(bless, format: :json)
end
