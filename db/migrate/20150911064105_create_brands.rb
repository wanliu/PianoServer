class CreateBrands < ActiveRecord::Migration
  def change
    create_table :brands do |t|
      t.string :name
      t.string :image
      t.string :chinese_name
      t.text :description
      t.jsonb :data

      t.timestamps null: false
    end
  end
end
