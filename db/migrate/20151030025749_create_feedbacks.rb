class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.string  :name
      t.string  :mobile
      t.text    :information
      t.boolean :is_show

      t.timestamps null: false
    end
  end
end
