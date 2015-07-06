class AddDataToRoom < ActiveRecord::Migration
  def change
    add_column :rooms, :data, :hstore
  end
end
