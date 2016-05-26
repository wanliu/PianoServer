class AddIndexToShops < ActiveRecord::Migration
  def change
    add_index :shops, :title
    add_index :shops, :name
    add_index :shops, :owner_id
  end
end
