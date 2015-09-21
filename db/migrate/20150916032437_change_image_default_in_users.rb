class ChangeImageDefaultInUsers < ActiveRecord::Migration
  def change
    change_column_default :users, :image, ''
  end
end
