json.array!(@gifts) do |gift|
  json.extract! gift, :id, :item_id, :present_id, :quantity, :total
  json.url gift_url(gift, format: :json)
end
