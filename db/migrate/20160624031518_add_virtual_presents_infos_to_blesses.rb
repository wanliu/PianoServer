class AddVirtualPresentsInfosToBlesses < ActiveRecord::Migration
  def change
    # add_column :blesses, :virtual_present_name, :string
    # add_column :blesses, :virtual_present_title, :string
    # add_column :blesses, :virtual_present_value, :decimal, precision: 10, scale: 2
    # add_column :blesses, :virtual_present_price, :decimal, precision: 10, scale: 2
    add_column :blesses, :virtual_present_infor, :jsonb
  end
end
