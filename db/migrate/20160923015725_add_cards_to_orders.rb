class AddCardsToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :cards, :string, array: true, default: '{}'

    add_index :orders, :cards, using: 'gin'
  end
end
