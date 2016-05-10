class AddGiftsOrderItem < ActiveRecord::Migration
  def change
    add_column :order_items, :gifts, :jsonb, default: {}
  end
end
