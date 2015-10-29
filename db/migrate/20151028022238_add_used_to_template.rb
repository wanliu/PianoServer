class AddUsedToTemplate < ActiveRecord::Migration
  def change
    add_column :templates, :used, :boolean, default: false
  end
end
