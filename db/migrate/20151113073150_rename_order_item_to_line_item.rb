class RenameOrderItemToLineItem < ActiveRecord::Migration
  def change
    rename_table :order_items, :line_items
  end
end
