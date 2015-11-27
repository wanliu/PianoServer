module OrderHelper
  def orderable_url(order_item)
    if order_item.orderable_type == 'Promotion'
      promotion_path order_item.orderable_id
    elsif order_item.orderable_type == 'Item'
      shop_item_path(order_item.orderable.shop.try(:name), order_item.orderable)
    else
      url_for order_item.orderable
    end
  end
end