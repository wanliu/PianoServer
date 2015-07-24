class AddImageToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :image, :jsonb
  end
end
