class RemoveThemeFromShops < ActiveRecord::Migration
  def change
    remove_column :shops, :theme, :string
  end
end
