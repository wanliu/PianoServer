class AddDefaultPropertiesToOrderItem < ActiveRecord::Migration
  def change
    change_column :cart_items, :properties, :jsonb, default: {}
    change_column :order_items, :properties, :jsonb, default: {}
  end
end
