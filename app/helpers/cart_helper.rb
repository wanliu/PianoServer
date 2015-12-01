module CartHelper
  def cart_item_avatar_url(cart_item)
    if cart_item.cartable_type == 'Promotion'
      cart_item.cartable.image_url
    elsif cart_item.cartable_type == 'Item'
      cart_item.cartable.avatar_url
    else
      url_for cart_item.cartable
    end
  end

  def cartable_url(cart_item)
    if cart_item.cartable_type == 'Promotion'
      promotion_path cart_item.cartable_id
    elsif cart_item.cartable_type == 'Item'
      shop_item_path(cart_item.cartable.shop.try(:name), cart_item.cartable)
    else
      url_for cart_item.cartable
    end
  end
end