class Item < ActiveRecord::Base
  belongs_to :itemable, polymorphic: true
end
