class Item < ActiveRecord::Base
  belongs_to :shop_category, class_name: 'Category'

  validates :shop_category, presence: true
  validates :shop, presence: true
  validates :price, presence: true
  validates :product_id, presence: true

  delegate :name, to: :product
  delegate :price, to: :product, prefix: true
  delegate :avatar, to: :product, allow_nil: true
  delegate :brand_name, to: :product, allow_nil: true
  delegate :category_id, to: :product, prefix: true
  delegate :additional_fields, to: :product, allow_nil: true

  def product
    Product.find(product_id)
  end

  def product=(p)
    self.product_id = p.id
  end
end
