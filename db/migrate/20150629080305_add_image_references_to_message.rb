class AddImageReferencesToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :image_ref_id, :integer
    add_column :messages, :image, :hstore
  end
end
