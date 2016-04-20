class ShopDeliver < ActiveRecord::Base
  belongs_to :shop
  belongs_to :deliver, class_name: 'User'
end
