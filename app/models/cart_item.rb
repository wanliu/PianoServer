class CartItem < ActiveRecord::Base
  enum sale_mode: [:retail, :wholesale]

  attr_accessor :sale_mode

  belongs_to :cart
  belongs_to :supplier, class_name: "Shop"

  belongs_to :cartable, polymorphic: true

  validates :price, :quantity, numericality: { greater_than: 0 }
  validates :supplier, presence: true
  validates :cart_id, presence: true
  validates :cartable_id, uniqueness: { scope: [:cart_id, :cartable_type] }

  validate :avoid_from_shop_owner

  delegate :title, to: :cartable, allow_nil: true

  def cartable
    if cartable_type == 'Promotion'
      Promotion.find(cartable_id)
    else
      super
    end
  end

  def quantity
    super || default_quantity
  end

  def default_quantity
    if cartable && cartable.respond_to?(:default_quantity)
      cartable.default_quantity || 1
    else
      1
    end
  end

  def avoid_from_shop_owner
    if supplier.owner_id == cart.user_id
      errors.add(:supplier_id, "不能购买自己店里的商品")
    end
  end
end
