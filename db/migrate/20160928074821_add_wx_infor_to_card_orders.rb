class AddWxInforToCardOrders < ActiveRecord::Migration
  def change
    add_column :card_orders, :wx_prepay_id, :string
    add_column :card_orders, :wx_noncestr, :string
    add_column :card_orders, :wx_transaction_id, :string
  end
end
