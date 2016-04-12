class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.references :item, index: true
      t.integer :present_id, index: true
      t.integer :quantity
      t.integer :total

      t.timestamps null: false
    end
    add_foreign_key :gifts, :items
  end
end
