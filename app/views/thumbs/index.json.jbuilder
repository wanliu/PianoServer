json.array!(@thumbs) do |thumb|
  json.extract! thumb, :id, :user_id, :thumbable_id, :thumbable_type
  json.url thumb_url(thumb, format: :json)
end
