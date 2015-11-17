class CreateOrder < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.references :buyer, index: true
      t.references :supplier, index: true
      t.decimal :total, precision: 10, scale: 2
      t.string :delivery_address
    end
    add_foreign_key :orders, :users, column: :buyer_id
    add_foreign_key :orders, :shops, column: :supplier_id
  end
end