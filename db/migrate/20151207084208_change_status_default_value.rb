class ChangeStatusDefaultValue < ActiveRecord::Migration
  def change
    change_column :shop_categories, :status, :boolean, default: true
  end
end
