class CartItem < ActiveRecord::Base
  enum sale_mode: [:retail, :wholesale]

  attr_accessor :sale_mode

  belongs_to :cart
  belongs_to :supplier, class_name: "Shop"

  belongs_to :cartable, polymorphic: true

  validates :price, :quantity, numericality: { greater_than: 0 }

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
end
