class StockChange < ActiveRecord::Base
  belongs_to :item
  belongs_to :unit
  belongs_to :operator
  belongs_to :operation
end
