json.array!(@virtual_presents) do |virtual_present|
  json.extract! virtual_present, :id, :price
  json.url virtual_present_url(virtual_present, format: :json)
end
