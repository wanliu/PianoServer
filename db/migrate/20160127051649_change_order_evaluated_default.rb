class ChangeOrderEvaluatedDefault < ActiveRecord::Migration
  def change
    change_column :orders, :evaluated, :boolean, default: false
  end
end
