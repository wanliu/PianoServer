class AddSortidToCategoriesProperties < ActiveRecord::Migration
  def change
    add_column :categories_properties, :sortid, :integer, default: 0
  end
end
