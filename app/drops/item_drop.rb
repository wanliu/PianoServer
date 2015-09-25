class ItemDrop < Liquid::Rails::Drop
  attributes :id, :title, :public_price, :price, :created_at, :updated_at, :image_url

  def image_url
    object.image.url
  end

  def link
    "/items/#{object.id}"
  end
end
