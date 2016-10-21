class CreateUserCards < ActiveRecord::Migration
  def change
    create_table :user_cards do |t|
      t.references :user, index: true
      t.references :card, index: true
      t.string :encrypt_code, index: true

      t.timestamps null: false
    end
  end
end
