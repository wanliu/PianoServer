class CreateVirtualCashChanges < ActiveRecord::Migration
  def change
    create_table :virtual_cash_changes do |t|
      t.references :user, index: true, foreign_key: true
      t.integer :amount
      t.integer :kind

      t.timestamps null: false
    end
  end
end
