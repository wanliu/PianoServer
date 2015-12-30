class PromotionDrop < Liquid::Rails::Drop
  attributes :id, :type, :title, :image_url, :image_mobile_url, :product_price,
    :product_inventory, :publisher_avatar, :shop_id, :category_id, :status,
    :discount_price, :discount, :avatar, :shop_name, :created_at,
    :updated_at, :shop_title, :logo_url, :avatar_url, :cover_url, :preview_url

  def shop_name
    object.shop.try(:name)
  end

  def shop_title
    object.shop.try(:title)
  end

  def link_shop_html
    shop_name + '.html'
  end
end
