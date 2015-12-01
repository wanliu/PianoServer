class AddRegionIdToShop < ActiveRecord::Migration
  def change
    add_column :shops, :region_id, :string
  end
end
