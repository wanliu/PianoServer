class AddSalesManIdToBirthdayParties < ActiveRecord::Migration
  def change
    add_reference :birthday_parties, :sales_man, index: true
  end
end
