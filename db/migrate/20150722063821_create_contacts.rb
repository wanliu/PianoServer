class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :mobile
      t.text :message

      t.timestamps null: false
    end
  end
end
