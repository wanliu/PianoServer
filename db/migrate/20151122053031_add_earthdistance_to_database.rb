class AddEarthdistanceToDatabase < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION cube'
    execute 'CREATE EXTENSION earthdistance'
  end

  def down
    execute 'drop EXTENSION earthdistance'
    execute 'drop EXTENSION cube'
  end
end
