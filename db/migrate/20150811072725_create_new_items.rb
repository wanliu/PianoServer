class CreateNewItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :shop_category
      t.integer :shop_id
      t.integer :product_id
      t.decimal :price, precision: 10, scale: 2
      t.integer :inventory
      t.boolean :on_sale, default: true
      t.timestamps null: false
    end
  end
end