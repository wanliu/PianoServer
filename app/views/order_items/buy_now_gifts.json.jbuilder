if @item.gifts.present?
  json.gifts @item.gifts do |gift|
    quantity = gift.eval_available_quantity(@quantity)
    if quantity > 0
      json.extract! gift, :avatar_url, :id, :present_id
      json.quantity quantity
      json.composed_title truncate(gift.composed_title, length: 15) 
    end
  end
end