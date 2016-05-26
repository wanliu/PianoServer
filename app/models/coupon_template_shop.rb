class CouponTemplateShop < ActiveRecord::Base
  enum kind: {
    include: 0,
    exclude: 1
  }

  belongs_to :coupon_template
  belongs_to :shop

  validates :shop, presence: true
  validates :coupon_template, presence: true

  before_create :set_type_by_coupon_template

  private

  def set_type_by_coupon_template
    self.kind = if coupon_template.include_shops?
      "include"
    elsif coupon_template.exclude_shops?
      "exclude"
    end
  end
end
