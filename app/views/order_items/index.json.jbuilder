json.array!(@order_items) do |order_item|
  json.extract! order_item, :id, :order_id, :orderable_id, :orderable_type, :title, :price, :quantity, :data, :properties
  json.url order_item_url(order_item, format: :json)
end
