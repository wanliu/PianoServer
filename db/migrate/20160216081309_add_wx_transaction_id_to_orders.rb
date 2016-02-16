class AddWxTransactionIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :wx_transaction_id, :string, index: true
  end
end
