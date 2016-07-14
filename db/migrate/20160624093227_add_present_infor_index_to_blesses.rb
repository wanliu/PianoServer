class AddPresentInforIndexToBlesses < ActiveRecord::Migration
  def change
    add_index :blesses, :virtual_present_infor, using: :gin
  end
end
