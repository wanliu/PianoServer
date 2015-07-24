class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.references :stateable, polymorphic: true
      t.integer :state
      t.timestamps null: false
    end
  end
end
