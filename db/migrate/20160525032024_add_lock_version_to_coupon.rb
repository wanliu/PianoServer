class AddLockVersionToCoupon < ActiveRecord::Migration
  def change
    add_column :coupons, :lock_version, :integer
  end
end
