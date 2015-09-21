class ShopDrop < Liquid::Rails::Drop
  attributes :id, :name, :logo_url, :title, :description, :address, :logo_url_cover, :link

  def link
    "/#{object.name}"
  end
end
