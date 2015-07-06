class AddMobileToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :mobile, :string
  	add_column :users, :username, :string

    add_index :users, :mobile,              unique: true
    add_index :users, :username, 			    unique: true  	
  end
end
