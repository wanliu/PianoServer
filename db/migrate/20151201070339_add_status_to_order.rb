class AddStatusToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :status, :integer, dafault: 0
  end
end
