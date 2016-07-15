class AddWxFieldsToBlesses < ActiveRecord::Migration
  def change
    add_column :blesses, :wx_prepay_id, :string
    add_column :blesses, :wx_noncestr, :string
    add_column :blesses, :wx_transaction_id, :string
  end
end
