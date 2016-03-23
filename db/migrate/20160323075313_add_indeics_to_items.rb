class AddIndeicsToItems < ActiveRecord::Migration
  def change
    add_index :items, :on_sale
    add_index :items, :shop_id
    add_index :items, :shop_category_id
    add_index :items, :sid
    add_index :items, :category_id
    add_index :items, :brand_id
  end
end
