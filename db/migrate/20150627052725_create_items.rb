class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.references :itemable, polymorphic: true
      t.string :title
      t.hstore :data
      t.integer :iid
      t.string :item_type
      t.timestamps null: false
    end
  end
end
