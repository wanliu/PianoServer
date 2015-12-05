json.array!(@shops_admin_orders) do |shops_admin_order|
  json.extract! shops_admin_order, :id
  json.url shops_admin_order_url(shops_admin_order, format: :json)
end
