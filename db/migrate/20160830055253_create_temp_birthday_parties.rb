class CreateTempBirthdayParties < ActiveRecord::Migration
  def change
    create_table :temp_birthday_parties do |t|
      t.references :cake, index: true
      t.integer :quantity
      t.integer :hearts_limit
      t.date :birth_day
      t.datetime :delivery_time
      t.references :user, index: true
      t.references :sales_man, index: true
      t.text :message
      t.string :delivery_address
      t.string :birthday_person
      t.string :person_avatar
      t.string :avatar_media_id

      t.timestamps null: false
    end
  end
end