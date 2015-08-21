class RemoveImageFromCategory < ActiveRecord::Migration
  def up
    remove_column :categories, :image
    add_column :categories, :image, :string
  end

  def down
    remove_column :categories, :image
    add_column :categories, :image, :jsonb, default: {}
  end

end
