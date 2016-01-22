class AddPaidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :paid, :boolean, default: false
    add_column :orders, :wx_prepare_id, :string
    add_column :orders, :wx_noncestr, :string
  end
end
