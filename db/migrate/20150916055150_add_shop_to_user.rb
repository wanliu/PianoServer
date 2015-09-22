class AddShopToUser < ActiveRecord::Migration
  def change
    add_column :users, :shop_id, :integer
  end
end
