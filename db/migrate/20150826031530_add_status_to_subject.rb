class AddStatusToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :status, :integer, default: 0
  end
end
