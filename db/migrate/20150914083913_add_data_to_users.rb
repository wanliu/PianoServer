class AddDataToUsers < ActiveRecord::Migration
  def up
    change_table :products do |t|
      add_column :users, :data, :jsonb, :default => {}
      execute 'CREATE INDEX index_users_on_data ON users USING gin (data jsonb_path_ops);'
    end
  end

  def down
    change_table :products do |t|
      execute 'DROP INDEX index_users_on_data;'
      remove_column :users, :data
    end
  end
end
