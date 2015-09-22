json.(@shop_category,  *@shop_category.attributes.keys)
json.html render partial: "shop_category", object: @shop_category, formats: [ :html ]

