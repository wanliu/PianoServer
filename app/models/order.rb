class Order < ActiveRecord::Base
  belongs_to :buyer
  belongs_to :supplier
end
