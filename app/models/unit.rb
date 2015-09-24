class Unit < ActiveRecord::Base

  has_many :properties

  paginates_per 10
end
