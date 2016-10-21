class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :wx_card_id, index: true
      t.integer :available_range, default: 0, index: true
      t.string :title, index: true

      t.timestamps null: false
    end
  end
end
