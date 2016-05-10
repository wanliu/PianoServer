class CreateShopDelivers < ActiveRecord::Migration
  def change
    create_table :shop_delivers do |t|
      t.references :shop, index: true
      t.references :deliver, index: true

      t.timestamps null: false
    end
    add_foreign_key :shop_delivers, :shops
    add_foreign_key :shop_delivers, :users, column: :deliver_id
  end
end
