class ItemDrop < Liquid::Rails::Drop
  attributes :id, :title, :public_price, :price, :created_at, :updated_at, :image_url, :image, :description, :hits, :shop_id, :sid

  def image_url
    object.image.url
  end

  def avatar_url
    object.image.url(:avatar)
  end

  def cover_url
    object.image.url(:cover)
  end

  def link
    "/items/#{object.sid}"
  end
end
