class AddPhoneToSalesMen < ActiveRecord::Migration
  def change
    add_column :sales_men, :phone, :string
  end
end
