class AddIssuedToCouponTemplate < ActiveRecord::Migration
  def change
    add_column :coupon_templates, :issued, :boolean, default: false
  end
end
