class AddShopIdToShopCategory < ActiveRecord::Migration
  def change
    add_reference :shop_categories, :shop, index: true
    add_foreign_key :shop_categories, :shops
  end
end
