require "./lib/coupon_time_duration"

class CouponTemplateTime < ActiveRecord::Base
  composed_of :expire_duration, class_name: 'CouponTimeDuration', mapping: %w(expire_duration to_h)

  # attr_reader :duration

  accessors = CouponTimeDuration::ATTR_NAMES
  delegate *accessors, to: :expire_duration, prefix: true
  delegate *(accessors.map {|writer| "#{writer}=" }), to: :expire_duration, prefix: true

  belongs_to :coupon_template

  validates :coupon_template, presence: true

  def self.permit_attributes
    duration_attrs = [{expire_duration_attributes: CouponTimeDuration::ATTR_NAMES}]
    duration_attrs.concat [:from, :to]
    # duration_attrs = CouponTimeDuration::ATTR_NAMES.map {|attr| "expire_duration_#{attr}".to_sym }
  end

  def duration
    expire_duration.duration
  end

  def expire_duration_attributes=(attrs)
    self.expire_duration = CouponTimeDuration.new(attrs)
  end
end