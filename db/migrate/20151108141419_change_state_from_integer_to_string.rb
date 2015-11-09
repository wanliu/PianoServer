class ChangeStateFromIntegerToString < ActiveRecord::Migration
  def change
    change_column :statuses, :state, :string
  end
end
