require 'wx_order'

class Order < ActiveRecord::Base
  include WxOrder

  extend OrdersCollectionSpreadsheet

  mount_uploader :wechat_native_qrcode, ImageUploader

  belongs_to :buyer, class_name: 'User'
  belongs_to :supplier, class_name: 'Shop'

  has_many :items, class_name: 'OrderItem', autosave: true, dependent: :destroy
  accepts_nested_attributes_for :items

  has_many :evaluations
  accepts_nested_attributes_for :evaluations

  has_one :birthday_party, inverse_of: :order
  accepts_nested_attributes_for :birthday_party

  has_many :consumed_card_codes

  attr_accessor :cart_item_ids, :address_id, :cake_id, :card,
    :consumed_card_ids, :unconsumed_card_ids, :unuseable_card_ids, :card_rollback

  enum status: { initiated: 0, finish: 1, deleted: 2 }

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
  before_create :assign_total, :generate_receive_token
  before_create :exam_cards
  after_create :consume_cards

  after_commit :send_notify_to_seller, on: :create

  paginates_per 5

  # 购物车礼品
  # create new order_items
  # delete relevant cart_items
  # inventory deducting
  # "options"=>{
  #   "13"=>{"16"=>"2", "14"=>"1"}, 
  #   "12"=>{"17"=>"-1.0", "19"=>"2", "22"=>"2"}, 
  #   "15"=>{"undefined"=>""}
  # }
  def cart_item_gifts=(options)
    @cart_item_ids = options.keys

    options.each do |cart_item_id, gift_setting|
      if gift_setting.has_key?("undefined")
        cart_item = CartItem.find_by(id: cart_item_id)
        unless cart_item.blank?
          items.build(
            price: cart_item.price, 
            quantity: cart_item.quantity, 
            title: cart_item.title, 
            orderable_type: cart_item.cartable_type, 
            orderable_id: cart_item.cartable_id, 
            properties: cart_item.properties)
        end
      else
        cart_item = CartItem.find_by(id: cart_item_id)

        unless cart_item.blank?
          items.build(
            price: cart_item.price, 
            quantity: cart_item.quantity, 
            title: cart_item.title, 
            orderable_type: cart_item.cartable_type, 
            orderable_id: cart_item.cartable_id,
            gifts: cart_item.gift_settings(gift_setting),
            properties: cart_item.properties)
        end
      end

      cart_item_id
    end
  end

  # 立即购买的礼品
  # create new order_items
  # delete relevant cart_items
  # inventory deducting
  # 与cart_item_gifts不同的是，这里的key(13, 12, 15)是商品item的id, 而cart_item_gifts的key是cart_item的id
  # "options"=>{
  #   "13"=>{"16"=>"2", "14"=>"1"}, 
  #   "12"=>{"17"=>"-1.0", "19"=>"2", "22"=>"2"}, 
  #   "15"=>{"undefined"=>""}
  # }
  def item_gifts=(options)
    options.each do |item_id, gift_setting|
      unless gift_setting.has_key?("undefined")
        item = Item.find_by(id: item_id)

        unless item.blank?
          order_item = items.find do |item|
            item.orderable_type == "Item" &&
              item.orderable_id.to_s == item_id
          end

          unless order_item.blank?
            order_item.gifts = order_item.gift_settings(gift_setting)
          end
        end
      end
    end
  end

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

  def card=(wx_card_id)
    @card = wx_card_id

    self.cards = [wx_card_id]
    # cards << wx_card_id
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
    self.transaction do
      CartItem.destroy(cart_item_ids) if cart_item_ids.present?
      begin
        set_express_fee

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

  def set_express_fee
    return 0 if address_id.blank?

    delivery_region_id = Location.find(address_id).region_id

    self.express_fee = items.reduce(0) do |sum, item|
      sum += item.express_fee(delivery_region_id)
    end
  end

  def items_count
    items.pluck(:quantity).reduce(:+) || 0
  end

  def gifts_count
    items.reduce(0) do |sum, item|
      sum += item.gifts.reduce(0) { |s, g| s += g["quantity"] }
    end
  end

  def items_and_gifts_count
    items_count + gifts_count
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

  def can_use_card?
    !finish? && pmo_grab_id.blank? && birthday_party.blank? && !card_used?
  end

  def birthday_party_order?
    birthday_party.present?
  end

  def created_within_30_minutes?
    created_at >= Time.now - 30.minutes
  end

  def cancelable?
    birthday_party_order? && initiated? && created_within_30_minutes?
  end

  def deleted!
    transaction do
      super

      items.each do |item|
        item.cancel_deduct_stocks!(buyer)
      end

      birthday_party.destroy! if birthday_party.present?
    end
  end

  def card_used?
    cards.present?
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

  def wx_order_notify_url
    "{Settings.app.website}/orders/#{id}/wx_notify"
  end

  def calculate_total
    items_total + (express_fee || 0)
  end

  private

  def assign_total
    self.origin_total = self.total = calculate_total
  end

  # ①检查card是否可用于本订单
  # ②检查card_id下是否有可用的code
  def exam_cards
    return if cards.blank?

    self.unuseable_card_ids = []

    cards.each do |wx_card_id|
      unless buyer.has_avaliable_code? wx_card_id
        unuseable_card_ids << wx_card_id
      end
    end

    unuseable_card_ids.blank?
  end

  def apply_card(card)
    # if card.CASH?
    #   if card.least_cost.present? && origin_total < card.least_cost
    #     return
    #   end

      self.total -= card.reduce_cost.to_f/100
    # end
  end

  # 核销一张指定id的卡券,并记录下来被核销的卡券code
  def consume_cards
    return if cards.blank?

    self.consumed_card_ids = []
    self.unconsumed_card_ids = []

    wx_cards = Card.where(wx_card_id: cards)

    wx_cards.each do |card|
      consumed_code = nil
      if buyer.consume_wx_card(card.wx_card_id) { |code| consumed_code = code }
        apply_card card
        consumed_card_ids << card.wx_card_id
        consumed_card_codes.create(user_id: buyer_id, code: consumed_code, wx_card_id: card.wx_card_id)
      else
        unconsumed_card_ids << card.wx_card_id
      end
    end

    if consumed_card_ids.blank?
      self.card_rollback = true
      raise Exception.new("微信卡券无效,请重新选择")
    else
      update_columns(total: total)
    end
  end

  def avoid_from_shop_owner
    if supplier_id == buyer_id
      errors.add(:supplier_id, "不能购买自己店里的商品")
    end
  end

  # status could noly change from "initated" to "finish" right now
  def status_transfer
    if status_changed? && status_changed?(from: "finish")
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
    seller_mobile = supplier.try(:owner).try(:mobile) || phone
    seller_id = supplier.try(:owner).try(:id)

    unless persisted? && Settings.promotions.one_money.sms_to_supplier && pmo_grab_id && seller_mobile
      return
    end

    order_url = Rails.application.routes.url_helpers.shop_admin_order_path(supplier.name, self)

    NotificationSender.delay.notify({"mobile" => seller_mobile, "order_id" => id, "order_url" => order_url, "seller_id" => seller_id})
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
