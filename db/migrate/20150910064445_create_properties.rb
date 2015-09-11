class CreateProperties < ActiveRecord::Migration
  def change
    create_table :properties do |t|
      t.string :name
      t.string :title
      t.string :summary
      t.jsonb :data
      t.integer :unit_id
      t.string :unit_type
      t.string :prop_type

      t.timestamps null: false
    end
  end
end
