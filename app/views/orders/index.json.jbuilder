json.array!(@orders) do |order|
  json.extract! order, :id, :buyer_id, :supplier_id, :total, :delivery_address
  json.url order_url(order, format: :json)
end
