module CartHelper
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