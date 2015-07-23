class CreateLocations < ActiveRecord::Migration
  def change
    create_table :locations do |t|
      t.references :user
      t.integer :province_id
      t.integer :city_id
      t.integer :region_id
      t.string :road
      t.string :zipcode
      t.string :contact # optional
      t.string :contact_phone # optional
      t.timestamps null: false
    end
  end
end
