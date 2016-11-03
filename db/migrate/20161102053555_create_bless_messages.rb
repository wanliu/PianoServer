class CreateBlessMessages < ActiveRecord::Migration
  def change
    create_table :bless_messages do |t|
      t.text :message
      t.references :bless, index: true
      t.references :sender, index: true

      t.timestamps null: false
    end
  end
end
