class ShopDrop < Liquid::Rails::Drop
  attributes :id, :name, :avatar_url, :logo_url, :title, :description, :address, :logo_url_cover, :link, :hits, :owner_id

  def link
    "/#{object.name}"
  end

  def week_hits
    @object.hits(1.week.ago)
  end
end
