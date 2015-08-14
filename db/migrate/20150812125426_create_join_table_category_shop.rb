class CreateJoinTableCategoryShop < ActiveRecord::Migration
  def change
    create_join_table :categories, :shops do |t|
      # t.index [:category_id, :shop_id]
      # t.index [:shop_id, :category_id]
    end
  end
end
