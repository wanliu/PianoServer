# 使用token的方式发送购物卷

class CouponToken < ActiveRecord::Base
  belongs_to :coupon_template
  belongs_to :customer

  validates :token, presence: true, uniqueness: true
  validates :coupon_template_id, presence: true
  validates :customer_id, presence: true

  class << self
    def find_or_generate(options)
      existed_record = find_by(coupon_template_id: options[:coupon_template_id], customer_id: options[:customer_id])

      if existed_record.present?
        existed_record
      else
        token = Devise.friendly_token

        while exists?(token: token) do
          token = Devise.friendly_token
        end

        create(
          coupon_template_id: options[:coupon_template_id], 
          customer_id: options[:customer_id],
          token: token
        )
      end
    end
  end

end
