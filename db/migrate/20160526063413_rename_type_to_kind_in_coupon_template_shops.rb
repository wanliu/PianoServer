class RenameTypeToKindInCouponTemplateShops < ActiveRecord::Migration
  def change
    rename_column :coupon_template_shops, :type, :kind
  end
end
