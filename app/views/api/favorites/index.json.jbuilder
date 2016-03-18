json.total @total

json.favorites @favorites do |favorite|
  json.extract! favorite, :id, :favoritable_type, :favoritable_id, :created_at
  json.favoritable favorite.favoritable
  json.favoritable_url url_for(favorite.favoritable)
end
