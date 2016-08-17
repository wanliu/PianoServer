class AddPriceOffsetToItems < ActiveRecord::Migration
  def change
    add_column :items, :price_offset, :jsonb, default: {}
    add_index :items, :price_offset, using: :gin
  end
end
