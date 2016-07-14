class AddWithdrewToBirthdayParties < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :withdrew, :decimal, precision: 10, scale: 2, default: 0
  end
end
