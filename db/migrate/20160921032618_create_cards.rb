class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :wx_card_id
      t.integer :available_range, default: 0
      t.string :title

      t.timestamps null: false
    end
  end
end
