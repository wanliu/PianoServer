class Property < ActiveRecord::Base

  has_and_belongs_to_many :categories
  belongs_to :unit

  attr_reader :category_id, :upperd

  def category_id
    read_attribute(:category_id)
  end

  def upperd?
    read_attribute(:upperd)
  end

  def inhibit?
    read_attribute(:state) == 1
  end
end
