class AddDescriptionToShopCategory < ActiveRecord::Migration
  def change
    add_column :shop_categories, :description, :text
  end
end
