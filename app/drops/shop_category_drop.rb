class ShopCategoryDrop < Liquid::Rails::Drop
  attributes :id, :name, :category_type, :iid, :parent_id, :depth, :children_count, :position, :data, :created_at, :updated_at, :image, :title, :shop_id, :is_leaf

  def link
    "/categories/#{object.id}"
  end

  def blank_image
    object.image.blank_image?
  end

  def cover_url
    object.image.url(:cover)
  end

  def avatar_url
    object.image.url(:avatar)
  end

  def parent
    object.parent
  end
end
