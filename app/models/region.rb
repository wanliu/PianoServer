class Region < ActiveRecord::Base

  acts_as_nested_set

  has_one :status, as: :stateable, dependent: :destroy
  delegate :state, to: :status, allow_nil: true

  def categories(industry)
    Category.joins(:industries, :regions)
  end
end
