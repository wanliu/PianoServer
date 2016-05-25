class Coupon < ActiveRecord::Base
  default_scope { order(id: :desc) }

  acts_as_paranoid

  paginates_per 10

  enum status: {
    appliable: 0,
    applied: 1,
    # expired: 2
  }

  scope :active, -> { where("start_time <= :now AND end_time > :now", now: Time.now) }
  scope :expired, -> { where("end_time < :now", now: Time.now) }

  belongs_to :coupon_template, counter_cache: true
  belongs_to :receiver_shop, class_name: 'Shop'
  belongs_to :customer, class_name: 'User'

  # receive target is somethins like a order item
  belongs_to :receive_taget, polymorphic: true

  validates :coupon_template, presence: true
  # validate :freeze_customer_id, on: :update

  def evaluate_duration_time
    if "from_draw" == coupon_template.apply_time
      now = Time.now

      self.start_time = now
      self.end_time = now + coupon_template.coupon_template_time.duration
    end
  end
end
