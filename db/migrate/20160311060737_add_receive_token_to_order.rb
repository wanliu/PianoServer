class AddReceiveTokenToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :receive_token, :string
  end
end
