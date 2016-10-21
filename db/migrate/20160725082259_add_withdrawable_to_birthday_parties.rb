class AddWithdrawableToBirthdayParties < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :withdrawable, :decimal, precision: 10, scale: 2, default: 0

    BirthdayParty.find_each do |party|
      party.update_withdrawable
    end
  end
end
