class AddSettingsToShop < ActiveRecord::Migration
  def change
    add_column :shops, :settings, :jsonb, default: {}
    remove_column :shops, :image
  end
end
