class RemoveAvailableRangeFromCards < ActiveRecord::Migration
  def change
    remove_column :cards, :available_range
  end
end
