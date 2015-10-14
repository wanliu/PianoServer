class CreateStockChanges < ActiveRecord::Migration
  def change
    create_table :stock_changes do |t|
      t.references :item, index: true, null: false
      t.decimal :quantity, precision: 10, scale: 2, null: false
      t.jsonb :data, default: {}
      t.references :unit, index: true
      t.references :operator, index: true, null: false
      t.references :operation, index: true, polymorphic: true

      t.timestamps null: false
    end
    add_foreign_key :stock_changes, :items
    add_foreign_key :stock_changes, :units
    add_foreign_key :stock_changes, :users, column: :operator_id
    # add_foreign_key :stock_changes, :operations
  end
end
