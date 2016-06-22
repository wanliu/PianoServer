class CreateRedpacks < ActiveRecord::Migration
  def change
    create_table :redpacks do |t|
      t.references :user, index: true#, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.references :birthday_party, index: true#, foreign_key: true
      t.string :nonce_str
      t.string :wx_order_no, index: true
      t.boolean :withdrew, index: true

      t.timestamps null: false
    end
  end
end
