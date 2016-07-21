class AddBirthdayIndexToBirthdayParties < ActiveRecord::Migration
  def change
    add_index :birthday_parties, :birth_day
  end
end
