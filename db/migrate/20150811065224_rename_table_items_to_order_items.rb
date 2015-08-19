class RenameTableItemsToOrderItems < ActiveRecord::Migration
  def change
    rename_table :items, :order_items
  end
end
