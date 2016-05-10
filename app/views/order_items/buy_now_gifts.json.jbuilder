if @item.gifts.present?
  json.gifts @item.gifts do |gift|
    quantity = gift.eval_available_quantity(@quantity)
    if quantity > 0
      json.extract! gift, :composed_title, :avatar_url, :id, :present_id
      json.quantity quantity
    end
  end
end