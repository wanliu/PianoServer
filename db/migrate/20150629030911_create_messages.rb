class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :messable, polymorphic: true
      t.text :text
      t.string :type
      t.belongs_to :from
      t.belongs_to :reply
      t.hstore :mentions
      t.boolean :read, default: false
      t.timestamps null: false
    end
  end
end
