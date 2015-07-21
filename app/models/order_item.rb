class OrderItem < ActiveRecord::Base
  self.table_name = "items"

  belongs_to :itemable, polymorphic: true
end
