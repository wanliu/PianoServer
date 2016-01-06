class AddOneMoneyIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :one_money_id, :integer
  end
end
