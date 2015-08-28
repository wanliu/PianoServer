class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :name
      t.string :filename
      t.references :attachable, polymorphic: true
      t.timestamps null: false
    end
  end
end
