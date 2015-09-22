class RenameCategoryToShopCategory < ActiveRecord::Migration
  def change
    rename_table :categories, :shop_categories
  end
end
