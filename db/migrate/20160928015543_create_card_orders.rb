class CreateCardOrders < ActiveRecord::Migration
  def change
    create_table :card_orders do |t|
      t.string :wx_card_id
      t.boolean :paid, default: false, index: true
      t.boolean :withdrew, default: false, index: true
      t.integer :pmo_grab_id, index: true
      t.integer :one_money_id, index: true
      t.references :item, index: true
      t.references :user, index: true
      t.decimal :price, precision: 10, scale: 2 
      t.string :title

      t.timestamps null: false
    end
  end
end
