class AddIssuedToCouponTemplate < ActiveRecord::Migration
  def change
    add_column :coupon_templates, :issued, :jsonb, default: {}
  end
end
