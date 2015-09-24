class Unit < ActiveRecord::Base

  has_many :properties

  validates :name, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true

  paginates_per 10
end
