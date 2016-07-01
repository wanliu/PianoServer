class AddStatusToRedpacks < ActiveRecord::Migration
  def change
    remove_column :redpacks, :sent, :boolean
    add_column :redpacks, :status, :integer, default: 0, index: true
  end
end
