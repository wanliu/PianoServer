json.array! @items do |item|
	json.(item, :id, :name, :product_id)
end