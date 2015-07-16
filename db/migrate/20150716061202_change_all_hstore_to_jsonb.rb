class ChangeAllHstoreToJsonb < ActiveRecord::Migration
  def change
    # WARRNING this is irreversible migrations
    change_column :items, :image, 'jsonb USING CAST(image AS jsonb)', null: false, default: '{}'
    change_column :users, :image, 'jsonb USING CAST(image AS jsonb)', null: false, default: '{}'
    change_column :logs, :data, 'jsonb USING CAST(data AS jsonb)', null: false, default: '{}'
    change_column :messages, :image, 'jsonb USING CAST(image AS jsonb)', null: false, default: '{}'
    change_column :messages, :mentions, 'jsonb USING CAST(mentions AS jsonb)', null: false, default: '{}'
    change_column :notifies, :image, 'jsonb USING CAST(image AS jsonb)', null: false, default: '{}'
    change_column :notifies, :data, 'jsonb USING CAST(data AS jsonb)', null: false, default: '{}'
    change_column :rooms, :data, 'jsonb USING CAST(data AS jsonb)', null: false, default: '{}'
  end
end
