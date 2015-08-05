class AddLocationToOrder < ActiveRecord::Migration
  def up
    remove_column :orders, :delivery_address
    remove_column :orders, :send_address
    add_column :orders, :delivery_location_id, :integer
    add_column :orders, :send_location_id, :integer
  end

  def down
    add_column :orders, :delivery_address, :string
    add_column :orders, :send_address, :string
    remove_column :orders, :delivery_location_id
    remove_column :orders, :send_location_id
  end
end
