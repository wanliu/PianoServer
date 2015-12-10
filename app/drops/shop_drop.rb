class ShopDrop < Liquid::Rails::Drop
  include ImageUrl

  attributes :id, :name, :title, :description, :address, :link, :hits, :owner_id, :poster, :shop_admin_link
  image_mount :logo


  def link
    "/#{object.name}"
  end

  def link_html
    link + '.html'
  end

  def week_hits
    @object.hits(1.week.ago)
  end

  def shop_admin_link
    "/#{object.name}/admin"
  end
end
