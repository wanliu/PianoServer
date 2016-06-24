class VirtualPresent < ActiveRecord::Base

  NAMES = %w(heart car house flower)

  validates :title, presence: true
  validates :name, inclusion: { in: NAMES }
  validates :name, uniqueness: true
  validates :price, numericality: { greater__than_or_equal_to: 0 }
  validates :value, numericality: { greater__than_or_equal_to: 0 }
end
