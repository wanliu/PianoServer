class ChangeAllHstoreToJsonb < ActiveRecord::Migration
  def change
    change_column :items, :image, 'jsonb USING CAST(image AS jsonb)', null: false, default: '{}'

  end
end
