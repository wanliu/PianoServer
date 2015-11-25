json.categories @categories, partial: "category", as: :category
json.items @items, partial: "item", as: :item
json.brand @brands, partial: "brand", as: :brand
json.meta do
  json.page params[:page]
  json.count @items.total_count
end

