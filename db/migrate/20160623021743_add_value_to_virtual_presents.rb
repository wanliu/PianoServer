class AddValueToVirtualPresents < ActiveRecord::Migration
  def change
    add_column :virtual_presents, :value, :decimal, precision: 10, scale: 2, default: 0
  end
end
