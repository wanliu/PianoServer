class AddPaidTotalToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paid_total, :decimal, precision: 10, scale: 2
  end
end
