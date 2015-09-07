class CreateSubjects < ActiveRecord::Migration
  def change
    create_table :subjects do |t|

      t.string :name
      t.string :title
      t.text :description
      t.datetime :start_at
      t.datetime :end_at
      t.string :condition

      t.timestamps null: false
    end
  end
end
