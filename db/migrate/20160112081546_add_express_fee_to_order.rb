class AddExpressFeeToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :express_fee, :decimal, precision: 10, scale: 2, default: 0
  end
end
