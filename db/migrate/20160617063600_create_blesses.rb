class CreateBlesses < ActiveRecord::Migration
  def change
    create_table :blesses do |t|
      t.integer :sender_id
      t.references :virtual_present, index: true
      t.text :message
      t.references :birthday_party, index: true
      t.boolean :paid

      t.timestamps null: false
    end
  end
end
