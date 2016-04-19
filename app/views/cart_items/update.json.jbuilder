json.sub_total number_to_currency(@item.price * @item.quantity)
json.ccount @item.cart.items_count
if @item.cartable.gifts.present?
  json.gifts @item.cartable.gifts do |gift|
    quantity = gift.available_quantity(@item.quantity)
    if quantity > 0
      json.extract! gift, :composed_title, :avatar_url
      json.quantity quantity
    end
  end
end