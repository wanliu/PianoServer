class Order < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, class_name: 'OrderItem', autosave: true, dependent: :destroy

  attr_accessor :cart_item_ids

  validates :supplier, presence: true
  validates :buyer, presence: true

  before_create :caculate_total

  paginates_per 5

  # create new order_items
  # delete relevant cart_items
  # inventory deducting
  def cart_item_ids=(ids)
    @cart_item_ids = ids

    ids.each do |cart_item_id|
      item = CartItem.find(cart_item_id)
      items.build(price: item.price, quantity: item.quantity, title: item.title, 
        orderable_type: item.cartable_type, orderable_id: item.cartable_id, properties: item.properties)
    end
  end

  def save_with_cart_items(operator)
    self.transaction do 
      CartItem.destroy(cart_item_ids)

      items.each do |item|
        item.deduct_stocks!(operator)
      end

      save
    end
  end

  private

  def caculate_total
    self.total = items.reduce(0) { |total, item| total += item.price * item.quantity }
  end
end
