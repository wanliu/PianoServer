class AddAbandomToItems < ActiveRecord::Migration
  def change
    add_column :items, :abandom, :boolean, default: false, null: false
  end
end
