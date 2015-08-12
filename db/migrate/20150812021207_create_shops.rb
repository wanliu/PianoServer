class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.integer :owner_id
      t.string :name
      t.string :title
      t.string :license_no
      t.string :website
      t.string :status
      t.integer :location_id
      t.integer :phone
      t.integer :industry_id
      t.jsonb :image
      t.text :description
      # t.jsonb :main_scope
      t.timestamps null: false
    end
  end
end
