class CreateNotifies < ActiveRecord::Migration
  def change
    create_table :notifies do |t|
      t.references :notifiable, polymophic: true
      t.belongs_to :user
      t.string :text
      t.string :target
      t.string :type
      t.hstore :image    
      t.hstore :data
      t.boolean :read, default: false
      t.timestamps null: false
    end
  end
end
