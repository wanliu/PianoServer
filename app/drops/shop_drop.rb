class ShopDrop < Liquid::Rails::Drop
  include ImageUrl

  attributes :id, :name, :title, :description, :address, :link, :hits, :owner_id
  image_mount :logo


  def link
    "/#{object.name}"
  end

  def week_hits
    @object.hits(1.week.ago)
  end
end
