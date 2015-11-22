class AddShopTypeToShop < ActiveRecord::Migration

  def change
    add_column :shops, :shop_type, :integer, default: 0
    add_column :shops, :lat, :float
    add_column :shops, :lon, :float
    add_column :shops, :location_id, :integer
  end
end
