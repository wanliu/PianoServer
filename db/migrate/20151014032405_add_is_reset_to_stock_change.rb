class AddIsResetToStockChange < ActiveRecord::Migration
  def change
    add_column :stock_changes, :is_reset, :boolean, default: false, null: false
    add_column :stock_changes, :kind, :integer, null: false
    add_index  :stock_changes, :is_reset
  end
end
