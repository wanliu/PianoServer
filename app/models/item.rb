class Item < ActiveRecord::Base
  belongs_to :shop_category

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

  scope :with_category, -> (category_id) do
    category_id.nil? ? all : where("shop_category_id = ?", category_id)
  end

  scope :with_query, -> (q) do
    q.nil? ? all : where("title like ?", "%#{q}%")
  end

  scope :with_shop, -> (shop_id) do
    shop_id.nil? ? all : where("shop_id = ?", shop_id)
  end

  def product
    Product.find(product_id)
  end

  def product=(p)
    self.product_id = p.id
  end
end
