class ItemDrop < Liquid::Rails::Drop
  attributes :id, :title, :public_price, :price, :created_at, :updated_at, :image_url, :image, :description, :hits, :shop_id, :sid
  include ImageUrl

  image_mount :image

  def link
    "/items/#{object.sid}"
  end
end
