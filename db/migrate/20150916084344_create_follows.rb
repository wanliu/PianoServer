class CreateFollows < ActiveRecord::Migration
  def change
    create_table :follows do |t|
      t.integer :follower_id
      t.string :follower_type
      t.integer :followable_id
      t.string :followable_type

      t.timestamps null: false
    end
  end
end
