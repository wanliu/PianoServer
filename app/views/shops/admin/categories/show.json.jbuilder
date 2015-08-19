json.(@category,  *@category.attributes.keys)
json.html render partial: "category", object: @category, formats: [ :html ]

