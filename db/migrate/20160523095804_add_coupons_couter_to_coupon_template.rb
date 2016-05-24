class AddCouponsCouterToCouponTemplate < ActiveRecord::Migration
  def change
    add_column :coupon_templates, :coupons_count, :integer
  end
end
