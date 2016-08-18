class AddDeletedAtToCakes < ActiveRecord::Migration
  def change
    add_column :cakes, :deleted_at, :datetime
    add_index :cakes, :deleted_at
  end
end
