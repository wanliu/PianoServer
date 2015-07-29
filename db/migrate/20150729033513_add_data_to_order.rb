class AddDataToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :data, :jsonb
  end
end
