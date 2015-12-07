class RemoveImageFalseFromUsers < ActiveRecord::Migration
  def up
    change_column :users, :image, :string, null: true
  end

  def down
    change_column :users, :image, :string, null: false
  end
end
