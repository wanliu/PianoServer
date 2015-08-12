class ShopCategory < ActiveRecord::Base
  has_ancestry cache_depth: true

  validates :name, presence: true, uniqueness: { scope: :shop_id }
  validates :shop_id, presence: true

  alias_method :has_children, :has_children?

  def shop
    Shop.find(shop_id)
  end

  def shop=(s)
    self.shop_id = s.id
  end

  def chain_name
    path.map(&:name)
  end
end
