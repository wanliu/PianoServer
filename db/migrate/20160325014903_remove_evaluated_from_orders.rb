class RemoveEvaluatedFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :evaluated
  end
end
