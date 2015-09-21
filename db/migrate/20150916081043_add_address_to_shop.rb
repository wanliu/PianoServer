class AddAddressToShop < ActiveRecord::Migration
  def change
    add_column :shops, :address, :string
    remove_column :shops, :location_id
  end
end
