class Item < ActiveRecord::Base
  belongs_to :shop_category

  validates :shop_category, presence: true
  validates :shop_id, presence: true
  validates :price, presence: true
  validates :product_id, presence: true

  delegate :name, to: :product, prefix: true
  delegate :price, to: :product, prefix: true
  delegate :avatar, to: :product, prefix: true
  delegate :status, to: :product, prefix: true
  delegate :brand, to: :product, prefix: true
  delegate :category, to: :product, prefix: true

  def shop
    Shop.find(shop_id)
  end

  def shop=(s)
    self.shop_id = s.id
  end

  def product
    Product.find(product_id)
  end

  def product=(p)
    self.product_id = p.id
  end
end
