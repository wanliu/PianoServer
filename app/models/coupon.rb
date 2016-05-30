class Coupon < ActiveRecord::Base
  default_scope { order(id: :desc) }

  scope :unoverlap, -> do
    joins(:coupon_template).where("coupon_templates.overlap = :overlap", overlap: false)
  end

  scope :overlap, -> do
    joins(:coupon_template).where("coupon_templates.overlap = :overlap", overlap: true)
  end

  scope :active, -> { where("coupons.start_time <= :now AND coupons.end_time > :now", now: Time.now) }
  scope :expired, -> { where("coupons.end_time < :now", now: Time.now) }

  scope :available_with_total, -> (amount) do
    where("coupon_templates.apply_minimal_total <= :amount", amount: amount)
  end

  enum status: {
    appliable: 0,
    applied: 1,
    # expired: 2
  }

  acts_as_paranoid

  paginates_per 10

  belongs_to :coupon_template, counter_cache: true
  belongs_to :receiver_shop, class_name: 'Shop'
  belongs_to :customer, class_name: 'User'

  # receive target is somethins like a order item
  belongs_to :receive_taget, polymorphic: true

  validates :coupon_template, presence: true
  # validate :freeze_customer_id, on: :update

  class << self
    def available_with_item(item, amount)
      shop_id = item.shop_id

      appliable.active.available_with_total(amount).available_with_shop(shop_id)
    end

    def available_with_shop(shop_id)
      all_shops = CouponTemplate.apply_shops["all_shops"]
      include_shops = CouponTemplate.apply_shops["include_shops"]
      exclude_shops = CouponTemplate.apply_shops["exclude_shops"]
      include_kind = CouponTemplateShop.kinds["include"]
      exclude_kind = CouponTemplateShop.kinds["exclude"]

      sql_options = {
        all_shops: all_shops,
        include_shops: include_shops,
        exclude_shops: exclude_shops,
        include_kind: include_kind,
        exclude_kind: exclude_kind,
        shop_id: shop_id
      }

      sql = <<-SQL
        coupon_templates.apply_shops = :all_shops
        OR (
          coupon_templates.apply_shops = :include_shops
          AND coupon_template_shops.kind = :include_kind
          AND coupon_template_shops.shop_id = :shop_id)
        OR (
          coupon_templates.apply_shops = :exclude_shops
          AND coupon_template_shops.kind = :exclude_kind
          AND :shop_id NOT IN (SELECT coupon_template_shops.shop_id))
      SQL

      joins(coupon_template: [:coupon_template_shops]).where(sql, sql_options)
    end
  end

  def evaluate_duration_time
    if "from_draw" == coupon_template.apply_time
      now = Time.now

      self.start_time = now
      self.end_time = now + coupon_template.coupon_template_time.duration
    end
  end

end
