json.supplier_id @item.supplier_id
json.sub_total @item.price * @item.quantity
json.ccount @item.cart.items_count
json.cart_item_id @item.id

if @item.cartable.gifts.present?
  json.gifts @item.cartable.gifts do |gift|
    quantity = gift.eval_available_quantity(@item.quantity)
    if quantity > 0
      json.extract! gift, :avatar_url, :id, :present_id
      json.composed_title truncate(gift.composed_title, length: 15)
      json.quantity quantity
    end
  end
end