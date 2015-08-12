class CreateShopCategories < ActiveRecord::Migration
  def change
    create_table :shop_categories do |t|
      t.integer :shop_id, null: false
      t.string :name, null: false
      t.string :ancestry
      t.integer :ancestry_depth

      t.timestamps null: false
    end
  end
end
