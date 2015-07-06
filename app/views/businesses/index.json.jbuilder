json.array!(@businesses) do |business|
  json.extract! business, :id
  json.url business_url(business, format: :json)
end
