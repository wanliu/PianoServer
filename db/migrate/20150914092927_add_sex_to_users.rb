class AddSexToUsers < ActiveRecord::Migration
  def change
    add_column :users, :sex, :integer, default: 1
    change_column :users, :image, :string
  end
end
