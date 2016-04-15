require 'wx_order'

class Order < ActiveRecord::Base
  include WxOrder

  extend OrdersCollectionSpreadsheet

  belongs_to :buyer, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, class_name: 'OrderItem', autosave: true, dependent: :destroy
  accepts_nested_attributes_for :items

  has_many :evaluations
  accepts_nested_attributes_for :evaluations

  attr_accessor :cart_item_ids
  attr_accessor :address_id, :request_ip

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
  before_create :caculate_total, :generate_receive_token

  after_commit :send_notify_to_seller, on: :create

  paginates_per 5

  # create new order_items
  # delete relevant cart_items
  # inventory deducting
  # ids: [
  #   1,
  #   {2: {gift_ids: [1, 2]}},
  #   {3: {gift_ids: [3, 4]}},
  #   4,
  #   5
  # ]
  def cart_item_ids=(ids)
    @cart_item_ids = ids.map do |id_item|
      if id_item.is_a? Hash
        cart_item_id = id_item.keys[0]
        item = CartItem.find_by(id: cart_item_id)
        unless item.blank?
          items.build(
            price: item.price, 
            quantity: item.quantity, 
            title: item.title, 
            orderable_type: item.cartable_type, 
            orderable_id: item.cartable_id, 
            gifts: item.gift_settings(id_item[cart_item_id], item.quantity),
            properties: item.properties)
        end
      else
        cart_item_id = id_item
        item = CartItem.find_by(id: cart_item_id)
        unless item.blank?
          items.build(price: item.price, quantity: item.quantity, title: item.title, 
            orderable_type: item.cartable_type, orderable_id: item.cartable_id, properties: item.properties)
        end
      end

      cart_item_id
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

  def receive_token
    return unless persisted?
    if super.blank?
      generate_receive_token
      save
    end

    # self.reload
    super
  end

  def save_with_items(operator)
    delivry_region_id = Location.find(address_id).region_id

    self.transaction do
      CartItem.destroy(cart_item_ids) if cart_item_ids.present?
      begin
        self.express_fee = 0

        items.each do |order_item|
          if order_item.orderable_type == "Item"
            self.express_fee += order_item.quantity * Item.find(order_item.orderable_id).delivery_fee_to(delivry_region_id)
          end
        end

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
        pmo_grab = PmoGrab[pmo_grab_id]
        one_money = OneMoney[one_money_id]

        unless pmo_grab.present? && one_money.present? && pmo_grab.status == 'pending'
          raise ActiveRecord::Rollback, "PmoGrab timout"
        end

        self.express_fee = get_pmo_express_fee
        save!

        items.each do |item|
          item.deduct_stocks!(operator)
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

  def evaluatable?
    finish?
  end

  def wait_for_evaluate?
    previous_changes["status"].present? &&
    previous_changes["status"].last == "finish"
  end

  def wait_for_yiyuan_evaluate?
    wait_for_evaluate? && pmo_grab_id.present?
  end

  def yiyuan_fullfilled?
    delivery_address.present?
  end

  def evaluations_list
    evaluations(true)

    items.reduce({}) do |result, item|
      evaluation = evaluations.find do |evan|
        evan.evaluationable_type == item.orderable_type &&
        evan.evaluationable_id == item.orderable_id
      end

      if evaluation.present?
        result[item.id.to_s] = evaluation
      end

      result
    end
  end

  def evaluations_list_with_build
    # evans = evaluations.to_a
    items.reduce({}) do |result, item|
      evaluation = evaluations.find do |evan|
        evan.evaluationable_type == item.orderable_type &&
        evan.evaluationable_id == item.orderable_id
      end

      result[item.id.to_s] = if evaluation.present?
        evaluation
      else
        evaluations.build(
          evaluationable_id: item.orderable_id,
          evaluationable_type: item.orderable_type)
      end

      result
    end
  end

  def get_pmo_express_fee
    express_fee = 0

    discharge_for_express? do |discharge, fee, discharge_express_fee_on|
      express_fee = fee
      # return fee
    end

    express_fee
  end

  def discharge_for_express?
    pmo_grab = PmoGrab[pmo_grab_id]

    if pmo_grab.blank?
      yield false, 0, 0 if block_given?
      return false
    end

    pmo_item = pmo_grab.pmo_item

    if pmo_item.blank?
      yield false, 0, 0 if block_given?
      return false
    end

    discharge_express_fee_on = pmo_item.max_free_fare

    discharge = discharge_express_fee_on.present? && items_total >= discharge_express_fee_on
    if discharge
      yield discharge, 0, discharge_express_fee_on if block_given?
    else
      yield discharge, pmo_item.fare, discharge_express_fee_on if block_given?
    end

    discharge
  end

  def items_total
    items.reduce(0) { |total, item| total += item.price * item.quantity }
  end

  private

  def caculate_total
    self.origin_total = self.total = items_total + (express_fee || 0)
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
    if total_changed?
      if finish? || paid?
        errors.add(:base, "不能修改订单总价，该订单已经完成，或者已经支付")
      end
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

  def send_notify_to_seller
    seller_mobile = supplier.try(:owner).try(:mobile)
    seller_id = supplier.try(:owner).try(:id)

    unless persisted? && Settings.promotions.one_money.sms_to_supplier && pmo_grab_id && seller_mobile
      return
    end

    order_url = Rails.application.routes.url_helpers.shop_admin_order_path(supplier.name, self)
    # NotificationSender.delay.send_sms({mobile: seller_mobile, order_id: id, order_url: order_url, seller_id: seller_id})
    NotificationSender.delay.notify({mobile: seller_mobile, order_id: id, order_url: order_url, seller_id: seller_id})
  end

  def generate_receive_token
    token = nil

    loop do
      token = Devise.friendly_token
      break token unless Order.where(receive_token: token).first
    end

    self.receive_token = token
  end
end
