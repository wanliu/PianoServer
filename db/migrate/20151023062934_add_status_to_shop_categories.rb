class AddStatusToShopCategories < ActiveRecord::Migration
  def change
    add_column :shop_categories, :status, :boolean
  end
end
