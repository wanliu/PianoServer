class AddDataToBirthdayParties < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :data, :jsonb
  end
end
