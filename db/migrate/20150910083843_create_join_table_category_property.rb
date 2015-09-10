class CreateJoinTableCategoryProperty < ActiveRecord::Migration
  def change
    create_join_table :categories, :properties do |t|
      # t.index [:category_id, :property_id]
      # t.index [:property_id, :category_id]
    end
  end
end
