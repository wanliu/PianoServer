class CreateIndustries < ActiveRecord::Migration
  def change
    create_table :industries do |t|
      t.string :name
      t.string :title
      t.text :description
      t.string :image

      t.timestamps null: false
    end
  end
end
