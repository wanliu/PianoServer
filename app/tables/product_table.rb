class ProductTable < TableCloth::Base
  # Define columns with the #column method
  column :id, :name, :avatar, :status, :category_id, :brand_id,
      :price, :created_at, :updated_at # :image_urls
end
