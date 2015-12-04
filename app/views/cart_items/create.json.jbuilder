json.extract! @item, *@item.attribute_names
json.items_count @item.cart.items.count
json.avatar_url @item.avatar_url
json.url cartable_url(@item)