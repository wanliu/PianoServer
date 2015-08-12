json.has_children @shop_category.has_children
json.items @items do |item|
  json.(item, :id, :name, :product_id)
end
json.shop_categories @shop_categories do |cate|
  json.(cate, :id, :name, :shop_id)
end