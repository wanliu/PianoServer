class CreateConsumedCardCodes < ActiveRecord::Migration
  def change
    create_table :consumed_card_codes do |t|
      t.references :user, index: true
      t.references :order, index: true
      t.string :wx_card_id, index: true
      t.string :code, index: true

      t.timestamps null: false
    end

    remove_column :orders, :consumed_codes
  end
end
