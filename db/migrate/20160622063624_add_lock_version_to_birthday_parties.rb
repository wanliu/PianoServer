class AddLockVersionToBirthdayParties < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :lock_version, :integer, default: 0
  end
end
