class AddActivedAtToTempBirthdayParties < ActiveRecord::Migration
  def change
    add_column :temp_birthday_parties, :actived_at, :timestamp
    add_index :temp_birthday_parties, :actived_at
  end
end
