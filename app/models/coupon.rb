class Coupon < ActiveRecord::Base
  belongs_to :coupon_template, counter_cache: true
  belongs_to :receiver_shop, class_name: 'Shop'
  belongs_to :customer, class_name: 'User'

  # receive target is somethins like a order item
  belongs_to :receive_taget, polymorphic: true

  validates :coupon_template, presence: true

  enum status: {
    active: 0,
    applied: 1,
    expired: 2
  }
end
