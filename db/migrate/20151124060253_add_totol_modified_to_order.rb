class AddTotolModifiedToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :total_modified, :boolean, default: false, null: false
    add_column :orders, :origin_total, :decimal, precision: 10, scale: 2
  end
end
