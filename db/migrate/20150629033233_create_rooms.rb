class CreateRooms < ActiveRecord::Migration
  def change
    create_table :rooms do |t|
      t.references :roomable, polymorphic: true
      t.string :name
      t.belongs_to :target, class_name: 'User'
      t.belongs_to :owner, class_name: 'User'
      t.timestamps null: false
    end
  end
end
