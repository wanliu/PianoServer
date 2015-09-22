class CreateCategory < ActiveRecord::Migration
  def change
    create_table :categories do |t|
      t.string :name
      t.string :title
      t.string :image
      t.string :ancestry
      t.integer :ancestry_depth, default: 0
      t.jsonb :data

      t.timestamps null: false
    end

    add_index :categories, :ancestry
  end
end
