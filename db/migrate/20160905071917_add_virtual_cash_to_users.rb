class AddVirtualCashToUsers < ActiveRecord::Migration
  def change
    add_column :users, :virtual_cash, :integer, default: 0
    add_column :users, :lock_version, :integer, default: 0
  end
end
