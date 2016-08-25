class CreateErrorRecords < ActiveRecord::Migration
  def change
    create_table :error_records do |t|
      t.string :name
      t.string :refer
      t.string :infor

      t.timestamps null: false
    end
  end
end
