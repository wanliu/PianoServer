class AddConsumedCodesToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :consumed_codes, :string, array: true, default: '{}'
  end
end
