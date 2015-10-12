class StockChange < ActiveRecord::Base
  belongs_to :item
  belongs_to :unit
  belongs_to :operator, class_name: 'User'
  belongs_to :operation, polymorphic: true
end
