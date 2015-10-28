class AddDefaultToStackChangeData < ActiveRecord::Migration
  def change
    change_column :stock_changes, :data, :jsonb, default: {}
  end
end
