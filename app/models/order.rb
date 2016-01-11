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
  validates :pmo_grab_id, uniqueness: true, allow_nil: true
  validates :one_money_id, presence: true, if: :pmo_grab_id

  validate :avoid_from_shop_owner
  validate :status_transfer, on: :update
  validate :change_total_on_initiated, on: :update
  validate :items_should_exist, on: :create

  before_save :set_modified, if: :total_changed?
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
    location = Location.find_by(id: id)

    return if location.blank?

    self.delivery_address = location.delivery_address_without_phone
    self.receiver_name = location.contact
    self.receiver_phone = location.contact_phone
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

  def save_with_pmo(operator)
    self.transaction do
      begin
        save!

        items.each do |item|
          item.deduct_stocks!(operator)
        end

        pmo_grab = PmoGrab[pmo_grab_id]
        unless pmo_grab.present? && pmo_grab.status == 'pending'
          raise ActiveRecord::RecordInvalid, "PmoGrab timout"
        end
        pmo_grab.ensure!
      rescue ActiveRecord::RecordInvalid => e
        raise ActiveRecord::Rollback
        false
      end
    end
  end

  def items_count
    items.pluck(:quantity).reduce(:+) || 0
  end

  def yiyuan_promotion?
    pmo_grab_id.present?
  end

  def yiyuan_fullfilled?
    delivery_address.present?
  end

  private

  def caculate_total
    self.origin_total = self.total = items.reduce(0) { |total, item| total += item.price * item.quantity }
  end

  def avoid_from_shop_owner
    if supplier_id == buyer_id
      errors.add(:supplier_id, "不能购买自己店里的商品")
    end
  end

  # status could noly change from "initated" to "finish" right now
  def status_transfer
    if status_changed? && !status_changed?(form: "initated", to: "finish")
      errors.add(:base, "错误的操作")
    end
  end

  # 暂时的解决：订单完成后不能再修改总价
  def change_total_on_initiated
    if total_changed? && finish?
      errors.add(:base, "不能修改已经完成的订单总价")
    end
  end

  def set_modified
    self.total_modified = true
  end

  def items_should_exist
    if items.blank?
      errors.add(:base, "订单中没有商品，无法创建订单")
    end
  end
end
