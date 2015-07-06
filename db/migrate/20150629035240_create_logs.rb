class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.references :loggable, polymorphic: true
      t.belongs_to :operator
      t.hstore :data
      t.string :action

      t.timestamps null: false
    end
  end
end
