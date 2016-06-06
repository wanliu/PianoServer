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

  attr_accessor :cart_item_ids, :address_id, :request_ip, :coupon_ids

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
  validate :coupons_owner_and_offset, on: :create

  before_save :set_modified, if: :total_changed?
  before_create :caculate_total, :generate_receive_token

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
  # 与cart_item_gifts不同的是，这里的key是商品item的id, 而cart_item_gifts的key是cart_item的id
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

        coupons.each(&:save!)

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

        coupons.each do |coupon|
          coupon.save!
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

  def coupons_offseted_total
    coupons.reduce(0) { |total, coupon| total += coupon.offset_par }
  end

  def coupons
    @coupons ||= buyer.coupons.joins(:coupon_template).where(id: coupon_ids).to_a
  end

  # what coupons can I use?
  def available_coupons(options={})
    if options[:coupon_ids].blank?
      initiate_coupons
    else
      coupons = buyer.coupons.includes(:coupon_template).where(id: options[:coupon_ids]).to_a

      if coupons.all?(&:overlap)
        unselectd_coupons = initiate_coupons.find_all(&:overlap) - coupons

        if unselectd_coupons.blank?
          []
        else
          next_avaliable_coupons(selected: coupons, unselectd_coupons: unselectd_coupons)
        end
      else
        []
      end
    end
  end

  private

  # 根据选定条件，穷举所有可能的组合，使得购物卷的选择组合不依赖于客户的选择次序
  # TODO 优化计算方法
  def next_avaliable_coupons(options)
    unselectd_coupons = options[:unselectd_coupons]
    unselectd_coupons.find_all do |coupon|
      coupons = options[:selected] | [coupon]
      coupons_available?(coupons)
    end
  end

  # 验证一个组合是否合法
  # 验证配对的循序按照从面额从大到小
  def coupons_available?(coupons)
    coupons_exam = coupons.clone
    coupons_enum = coupons.sort_by(&:par).reverse

    left_items = items.each(&:reset_offset_remain).sort_by(&:offset_remain).reverse

    # multiple = options[:multiple] || false

    coupons_enum.each do |coupon|
      left_items.sort_by(&:offset_remain).reverse.each do |item|
        # if coupon.avalible_for(item)
        #   item.apply_coupon(coupon, multiple)
        next if item.offseted

        if coupon.apply_minimal_total <= item.total
          coupon.offset_par = [item.offset_remain, coupon.par].min
          item.offset_remain = item.offset_remain - coupon.par

          if item.offset_remain <= 0
            item.offset_remain = 0
            item.offseted = true
          end

          coupon.assign_attributes(receive_taget: item, status: 'applied')
          coupons_exam.delete coupon

          break
        else
          next
        end
      end
    end

    # 配对完毕之后，coupons数组应该是空的
    coupons_exam.blank?
  end

  def caculate_total
    self.origin_total = items_total + (express_fee || 0)
    self.offseted_total = coupons_offseted_total
    self.total = origin_total - offseted_total
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

  def initiate_coupons
    items.map do |item|
      if "Item" == item.orderable_type
        buyer.coupons.includes(:coupon_template).available_with_item(item.orderable, item.offset_remain).to_a
      end
    end.flatten.compact.uniq
  end

  def coupons_owner_and_offset
    return if coupon_ids.blank?
    if buyer.coupons.appliable.active.exists?(id: coupon_ids)
      unless coupons_available?(coupons)
        errors.add(:coupon_ids, "使用了无效的购物卷，请重新选择购物卷！")
      end
    else
      errors.add(:coupon_ids, "使用了无效的购物卷，请重新选择购物卷！")
    end
  end
end
