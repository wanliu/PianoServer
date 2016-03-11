class AddItemShopCategoryIndexToItems < ActiveRecord::Migration
  def change
    add_index :items, :shop_category_id
  end
end
