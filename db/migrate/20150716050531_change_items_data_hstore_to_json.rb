class ChangeDataHstoreToJson < ActiveRecord::Migration
  def change
    change_column :items, :data, 'jsonb USING CAST(data AS jsonb)', null: false, default: '{}'
  end
end
