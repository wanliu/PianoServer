class AddInventorySettingToItem < ActiveRecord::Migration
  def change
    add_column :items, :properties_setting, :jsonb, default: {}
  end
end