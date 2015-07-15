class AddTitleToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :title, :string
    add_column :orders, :total, :decimal, :precision => 18, :scale => 2
  end
end
