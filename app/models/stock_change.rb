class StockChange < ActiveRecord::Base
  belongs_to :item
  belongs_to :unit
  belongs_to :operator, class_name: 'User'
  belongs_to :operation, polymorphic: true

  enum kind: { purchase: 0, sale: 1, sale_refund: 2, stock_refund: 3, adjust: 4 }
end
