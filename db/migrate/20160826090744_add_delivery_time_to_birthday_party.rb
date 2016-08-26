class AddDeliveryTimeToBirthdayParty < ActiveRecord::Migration
  def change
    add_column :birthday_parties, :delivery_time, :datetime
  end
end
