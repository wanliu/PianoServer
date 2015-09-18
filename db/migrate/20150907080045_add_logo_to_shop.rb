class AddLogoToShop < ActiveRecord::Migration
  def change
    add_column :shops, :logo, :string
  end
end
