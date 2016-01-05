class AddPmoGrabIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :pmo_grab_id, :integer
  end
end
