class AddReceiverNameAndReceiverPhoneToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :receiver_name, :string
    add_column :orders, :receiver_phone, :string
  end
end
