class PromotionDrop < Liquid::Rails::Drop
  attributes :id, :title, :image_url, :product_price, :product_inventory,
    :shop_id, :category_id, :status, :discount_price, :discount, :avatar

end
