class RemoveDeliveryFeeFromItems < ActiveRecord::Migration
  def change
    remove_column :items, :delivery_fee, :jsonb
  end
end
