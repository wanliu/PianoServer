class CreateBirthdayParties < ActiveRecord::Migration
  def change
    create_table :birthday_parties do |t|
      t.references :cake, index: true
      t.references :user, index: true
      t.references :order, index: true
      t.integer :hearts_limit
      t.date :birth_day
      t.string :birthday_person
      t.string :person_avatar
      t.text :message

      t.timestamps null: false
    end
  end
end
