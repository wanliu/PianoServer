class AddTitleToItem < ActiveRecord::Migration
  def change
    add_column :items, :sid, :integer
    add_column :items, :title, :string
    add_column :items, :category_id, :integer
    add_column :items, :public_price, :decimal, precision: 10, scale: 2
    add_column :items, :income_price, :decimal, precision: 10, scale: 2
  end
end
