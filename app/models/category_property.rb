class CategoryProperty < ActiveRecord::Base
  self.table_name = "categories_properties"
  self.primary_keys = :category_id, :property_id

end
