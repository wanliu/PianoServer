class CreateOrderItems < ActiveRecord::Migration
  def change
    create_table :order_items do |t|
      t.references :order, index: true
      t.references :orderable, polymorphic: true, index: true
      t.string :title, null: false
      t.decimal :price, precision: 10, scale: 2
      t.integer :quantity, null: false
      t.jsonb :data
      t.jsonb :properties

      t.timestamps null: false
    end
    add_foreign_key :order_items, :orders
  end
end
