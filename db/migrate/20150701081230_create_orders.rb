class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.belongs_to :buyer
      t.belongs_to :seller
      t.belongs_to :suppiler
      t.string :send_address
      t.string :delivery_address
      t.string :contacts
      t.integer :business_type
      t.integer :bid
      t.integer :sid

      t.timestamps null: false
    end
  end
end
