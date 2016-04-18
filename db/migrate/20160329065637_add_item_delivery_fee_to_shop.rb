class AddItemDeliveryFeeToShop < ActiveRecord::Migration
  def change
    add_column :shops, :item_delivery_fee, :jsonb, default: {}
  end
end
