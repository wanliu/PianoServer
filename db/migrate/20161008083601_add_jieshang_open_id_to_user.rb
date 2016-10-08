class AddJieshangOpenIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :js_open_id, :string, index: true
    add_index :users, :js_open_id
  end
end
