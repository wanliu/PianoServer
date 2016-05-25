class AddLockVersionToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :lock_version, :integer, default: 0
  end
end
