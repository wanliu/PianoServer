class CreateCakes < ActiveRecord::Migration
  def change
    create_table :cakes do |t|
      t.references :item, index: true#, foreign_key: true
      t.integer :hearts_limit

      t.timestamps null: false
    end
  end
end
