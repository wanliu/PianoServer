class RenameOrderToIntention < ActiveRecord::Migration
  def change
    rename_table :orders, :intentions
  end
end
