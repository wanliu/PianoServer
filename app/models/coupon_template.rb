class CouponTemplate < ActiveRecord::Base
  default_scope { order(id: :desc) }

  SYSTEM_MARKER = "System"
  scope :system_templates, -> () { where(issuer_type: SYSTEM_MARKER) }

  SYSTEM_ISSUER = OpenStruct.new(
    name: "system_issuer",
    title: "系统",
    avatar_url: '',
    coupon_templates: CouponTemplate.system_templates
  ).freeze

  enum apply_items: {
    all_items: 0, 
    include_category: 1,
    exclude_category: 2,
    include_shop_category: 3,
    exclude_shop_category: 4,
    include_items: 5,
    exclude_items: 6
  }

  enum apply_shops: {
    all_shops: 0,
    include_shops: 1,
    exclude_shops: 2
  }

  enum apply_time: {
    fixed: 0,
    from_draw: 1
  }

  attr_reader :issue_quantity

  belongs_to :issuer, polymorphic: true

  has_many :coupons
  has_many :drawed_coupons, -> { where "customer_id IS NOT NULL" }, class_name: 'Coupon'
  has_many :applied_coupons, -> { where status: Coupon.statuses[:applied] }, class_name: 'Coupon'

  has_many :coupon_tokens

  has_one :coupon_template_time, dependent: :nullify, inverse_of: :coupon_template
  accepts_nested_attributes_for :coupon_template_time

  validates :issuer, presence: true, unless: :system_template?
  validates :name, presence: true, uniqueness: { scope: [:issuer_type, :issuer_id] }
  validates :par, presence: true
  validates :apply_items, presence: true
  validates :apply_minimal_total, presence: true
  validates :apply_shops, presence: true
  validates :issue_quantity, numericality: { only_integer: true, greater_than: 0 }, on: :update
  validates :overlap, inclusion: { in: [true, false] }
  validates :issued, inclusion:  { in: [true, false] }

  class << self
    def translate_enum_label(enum_name)
      Proc.new do |enum_option|
        i18n_scope = "activerecord.attributes.coupon_template.#{enum_name}"
        I18n.t(enum_option.first, scope: i18n_scope)
      end
    end
  end

  def issue_quantity=(quantity)
    @issue_quantity = quantity.try(:to_i)
  end

  def issuer
    if system_template?
      SYSTEM_ISSUER
    else
      super
    end
  end

  def create_coupons
    transaction do
      issue_quantity.times { create_coupon }

      update(issued: true)
    end
  end

  # 使用乐观锁来对coupon进行更新和删除coupon_token，避免竞态条件
  def allocate_coupon(customer, coupon_token)
    coupon = allocate(customer)
    if coupon.present? && !coupon.changed?
      coupon_token.destroy
      coupon
    else
      false
    end
  rescue ActiveRecord::StaleObjectError => e
    coupon.update_attribute("customer_id", nil)
    false
  end

  private

  def create_coupon
    options = if "fixed" == apply_time
      { start_time: coupon_template_time.from, end_time: coupon_template_time.to }
    else
      {}
    end

    coupons.create options
  end

  def system_template?
    SYSTEM_MARKER == issuer_type
  end

  def allocate(customer)
    coupon = coupons.where("customer_id IS NULL").order("RANDOM()").limit(1).first

    if coupon.present?
      coupon.update(customer_id: customer.id)
    end
    coupon
  rescue ActiveRecord::StaleObjectError => e
    allocate(customer)
  end
end
