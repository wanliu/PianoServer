class AddCurrentStockToItem < ActiveRecord::Migration
  def change
    add_column :items, :current_stock, :decimal, precision: 10, scale: 2

    Item.find_each do |item|
      item.update_attribute "current_stock", item.stock_changes.sum(:quantity)
    end
  end
end
