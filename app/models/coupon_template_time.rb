require "./lib/coupon_time_duration"

class CouponTemplateTime < ActiveRecord::Base
  attr_reader :duration

  accessors = %w(year month day hour min sec)
  delegate *accessors, to: :expire_duration, prefix: true
  delegate *(accessors.map {|write| "#{write}=" }), to: :expire_duration, prefix: true

  belongs_to :coupon_template

  composed_of :expire_duration, class_name: 'CouponTimeDuration', mapping: %w(expire_duration duration)
end