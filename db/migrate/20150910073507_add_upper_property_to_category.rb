class AddUpperPropertyToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :upper_properties_id, :integer
  end
end
