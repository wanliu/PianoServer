class AddValueToVirtualPresents < ActiveRecord::Migration
  def change
    add_column :virtual_presents, :value, :decimal, default: 0
  end
end
