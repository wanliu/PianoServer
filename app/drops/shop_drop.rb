class ShopDrop < Liquid::Rails::Drop
  attributes :id, :name, :logo_url, :title, :description, :address, :logo_url_cover, :link, :owner_id

  def link
    "/#{object.name}"
  end
end
