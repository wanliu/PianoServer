class ShopCategoryDrop < Liquid::Rails::Drop
  attributes :id, :name, :category_type, :iid, :parent_id, :depth, :children_count, :position, :data, :created_at, :updated_at, :image, :title, :shop_id, :is_leaf, :hits
  include ImageUrl

  image_mount :image

  def link
    "/categories/#{object.id}"
  end

  def parent
    object.parent
  end
end
