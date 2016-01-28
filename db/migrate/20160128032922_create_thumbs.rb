class CreateThumbs < ActiveRecord::Migration
  def change
    create_table :thumbs do |t|
      t.references :thumber, index: true
      t.references :thumbable, polymorphic: true, index: true

      t.timestamps null: false
    end
    add_foreign_key :thumbs, :users, column: :thumber_id
  end
end
