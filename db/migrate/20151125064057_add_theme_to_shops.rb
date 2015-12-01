class AddThemeToShops < ActiveRecord::Migration
  def change
    add_column :shops, :theme, :string, default: 'theme1'
  end
end
