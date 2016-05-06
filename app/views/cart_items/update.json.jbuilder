json.supplier_id @item.supplier_id
json.sub_total @item.price * @item.quantity
json.ccount @item.cart.items_count
json.cart_item_id @item.id

if @item.cartable.gifts.present?
  json.gifts @item.cartable.gifts do |gift|
    quantity = gift.available_quantity(@item.quantity)
    if quantity > 0
      json.extract! gift, :composed_title, :avatar_url, :id, :present_id
      json.quantity quantity
    end
  end
end