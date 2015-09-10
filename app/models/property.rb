class Property < ActiveRecord::Base

  has_and_belongs_to_many :categories

  belongs_to :unit
end
