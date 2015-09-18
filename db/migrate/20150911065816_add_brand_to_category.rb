class AddBrandToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :brand_id, :integer
  end
end
