class AddOffsetdTotalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :offseted_total, :decimal, precision: 10, scale: 2, default: 0
  end
end
