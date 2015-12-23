class AddGenderToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :gender, :integer, default: 1, null: 1
  end
end
