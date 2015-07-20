class AddPriceAndAmountToItem < ActiveRecord::Migration
  def change
    add_column :items, :price, :decimal, :precision => 15, :scale => 2
    add_column :items, :amount, :decimal, :precision => 15, :scale => 8
    add_column :items, :sub_total, :decimal, :precision => 16, :scale => 2
    add_column :items, :unit, :integer
    add_column :items, :unit_title, :string
  end
end
