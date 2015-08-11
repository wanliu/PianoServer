json.array! @shop_categories do |cate|
  json.(cate, :id, :name, :shop_id)
end