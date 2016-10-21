class AddBirthdayPartyIdToTempBirthdayParties < ActiveRecord::Migration
  def change
    add_reference :temp_birthday_parties, :birthday_party, index: true
  end
end
