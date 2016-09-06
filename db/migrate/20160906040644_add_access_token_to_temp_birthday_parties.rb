class AddAccessTokenToTempBirthdayParties < ActiveRecord::Migration
  def change
    add_column :temp_birthday_parties, :access_token, :string
    add_index :temp_birthday_parties, :access_token

    TempBirthdayParty.all.each do |party|
      party.send(:generate_access_token)
      party.save
    end
  end
end
