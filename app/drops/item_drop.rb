class ItemDrop < Liquid::Rails::Drop
  attributes :id, :title, :public_price, :price, :created_at, :updated_at, :image_url, :description

  def image_url
    object.image.url
  end

  def avatar_url
    object.image.url(:avatar)
  end

  def link
    "/items/#{object.id}"
  end
end
