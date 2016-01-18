if params[:inline]
  json.(item, :id, :title, :on_sale, :public_price, :price, :current_stock)
  json.html render partial: "item", object: item, formats: [ :html ]
else
  json.(item, *item.attributes.keys)
end
