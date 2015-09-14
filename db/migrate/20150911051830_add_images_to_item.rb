class AddImagesToItem < ActiveRecord::Migration
  def change
    add_column :items, :images, :jsonb, default: []
  end
end
