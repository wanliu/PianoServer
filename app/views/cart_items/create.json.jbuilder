json.extract! @item, *@item.attribute_names
json.items_count @item.cart.items.count
json.avatar_url cart_item_avatar_url(@item)
json.url cartable_url(@item)