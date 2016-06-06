class RemoveItemDeliveryFeeFromShops < ActiveRecord::Migration
  def change
    remove_column :shops, :item_delivery_fee, :jsonb
  end
end
