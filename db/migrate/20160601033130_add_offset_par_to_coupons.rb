class AddOffsetParToCoupons < ActiveRecord::Migration
  def change
    add_column :coupons, :offset_par, :decimal, precision: 10, scale: 2
  end
end
