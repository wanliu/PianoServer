json.extract! @item, *@item.attribute_names
json.items_count current_cart.items_count
json.avatar_url @item.avatar_url
json.url cartable_url(@item)