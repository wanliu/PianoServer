class AddDescToCouponTemplate < ActiveRecord::Migration
  def change
    add_column :coupon_templates, :desc, :text
  end
end
