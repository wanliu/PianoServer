class AddLatestLocationIdToUser < ActiveRecord::Migration
  def up
    add_column :users, :latest_location_id, :integer
  end

  def down
    remove_column :orders, :latest_location_id
  end
end


