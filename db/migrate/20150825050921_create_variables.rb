class CreateVariables < ActiveRecord::Migration
  def change
    create_table :variables do |t|
      t.belongs_to :template
      t.string :name
      t.string :data_type
      t.jsonb :data
      t.string :type
      t.timestamps null: false
    end
  end
end
