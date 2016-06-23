class VirtualPresent < ActiveRecord::Base
  validates :name, presence: true
  validates :price, numericality: { greater__than_or_equal_to: 0 }
  validates :value, numericality: { greater__than_or_equal_to: 0 }
end
