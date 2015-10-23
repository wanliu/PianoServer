class ShopDrop < Liquid::Rails::Drop
  attributes :id, :name, :logo_url, :title, :description, :address, :logo_url_cover, :link, :hits

  def link
    "/#{object.name}"
  end
end
