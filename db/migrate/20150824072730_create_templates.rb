class CreateTemplates < ActiveRecord::Migration
  def change
    create_table :templates do |t|
      t.string :name
      t.string :filename
      t.belongs_to :last_editor, class_name: "User"
      t.belongs_to :subject

      t.timestamps null: false
    end
  end
end
