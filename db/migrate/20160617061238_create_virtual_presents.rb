class CreateVirtualPresents < ActiveRecord::Migration
  def change
    create_table :virtual_presents do |t|
      t.decimal :price, precision: 10, scale: 2
      t.string :name

      t.timestamps null: false
    end
  end
end
