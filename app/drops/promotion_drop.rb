class PromotionDrop < Liquid::Rails::Drop
  attributes :id, :type, :title, :image_url, :product_price, :product_inventory, :publisher_avatar,
    :shop_id, :category_id, :status, :discount_price, :discount, :avatar,
    :shop_name, :created_at, :updated_at, :shop_title

  def shop_name
    object.shop.try(:name)
  end

  def shop_title
    object.shop.try(:title)
  end
end
