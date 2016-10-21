class AddActiveTokenToTempBirthdayParties < ActiveRecord::Migration
  def change
    add_column :temp_birthday_parties, :active_token, :string, index: true
    add_column :temp_birthday_parties, :active_token_qrcode, :string
  end
end
