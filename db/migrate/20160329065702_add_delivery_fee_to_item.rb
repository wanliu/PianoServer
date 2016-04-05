class AddDeliveryFeeToItem < ActiveRecord::Migration
  def change
    add_column :items, :delivery_fee, :jsonb, default: {}
  end
end
