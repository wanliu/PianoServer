class CreateJoinTableCategoryProperty < ActiveRecord::Migration
  def change
    create_join_table :categories, :properties do |t|
      t.integer :state, default: 0
      # 0 == normal
      # 1 == deleted

      t.index :state
      t.index [:category_id, :property_id]
      t.index [:property_id, :category_id]
    end
  end
end
