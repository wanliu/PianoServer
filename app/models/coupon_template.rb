class CouponTemplate < ActiveRecord::Base
  SYSTEM_MARKER = "System"

  scope :system_templates, -> () { where(issuer_type: SYSTEM_MARKER) }

  default_scope -> { order(id: :desc) }

  SYSTEM_ISSUER = OpenStruct.new(
    name: "system_issuer",
    title: "系统",
    avatar_url: '',
    coupon_templates: CouponTemplate.system_templates
  ).freeze

  belongs_to :issuer, polymorphic: true

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

  validates :issuer, presence: true, unless: :system_template?
  validates :name, presence: true, uniqueness: { scope: [:issuer_type, :issuer_id] }
  validates :par, presence: true
  validates :apply_items, presence: true
  validates :apply_minimal_total, presence: true
  validates :overlap, presence: true
  validates :apply_shops, presence: true

  def issuer
    if system_template?
      SYSTEM_ISSUER
    else
      super
    end
  end

  def system_template?
    SYSTEM_MARKER == issuer_type
  end
end
