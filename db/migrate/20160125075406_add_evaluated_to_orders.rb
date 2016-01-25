class AddEvaluatedToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :evaluated, :boolean, defalut: false, index: true
  end
end
