class CreateSuggestions < ActiveRecord::Migration
  def change
    create_table :suggestions do |t|
      t.string :title, index: true
      t.integer :count, index: true, default: 0
      t.boolean :check, index: true, default: false

      t.timestamps null: false
    end
  end
end
