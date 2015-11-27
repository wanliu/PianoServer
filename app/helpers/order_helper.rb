module OrderHelper
  def orderable_url(order_item)
    if order_item.orderable == 'Promotion'
      promotion_path order_item.cartable_id
    elsif order_item.orderable == 'Item'
      shop_item_path(order_item.cartable.shop.try(:name), order_item.cartable)
    else
      url_for order_item.cartable
    end
  end
end