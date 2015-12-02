class Order < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, class_name: 'OrderItem', autosave: true, dependent: :destroy
  accepts_nested_attributes_for :items

  attr_accessor :cart_item_ids
  attr_accessor :address_id

  enum status: { initiated: 0, finish: 1 }

  validates :supplier, presence: true
  validates :buyer, presence: true
  validates :delivery_address, presence: true

  before_create :caculate_total

  paginates_per 5

  # create new order_items
  # delete relevant cart_items
  # inventory deducting
  def cart_item_ids=(ids)
    @cart_item_ids = ids

    ids.each do |cart_item_id|
      item = CartItem.find_by(id: cart_item_id)

      next if item.blank?

      items.build(price: item.price, quantity: item.quantity, title: item.title, 
        orderable_type: item.cartable_type, orderable_id: item.cartable_id, properties: item.properties)
    end
  end

  def address_id=(id)
    @address_id = id
    self.delivery_address = Location.find_by(id: id).to_s
  end

  def save_with_items(operator)
    self.transaction do 
      CartItem.destroy(cart_item_ids) if cart_item_ids.present?
      begin
        save!

        items.each do |item|
          item.deduct_stocks!(operator)
        end
      rescue ActiveRecord::RecordInvalid => e
        raise ActiveRecord::Rollback
        false
      end
    end
  end

  private

  def caculate_total
    self.origin_total = self.total = items.reduce(0) { |total, item| total += item.price * item.quantity }
  end
end
