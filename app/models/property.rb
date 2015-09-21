class Property < ActiveRecord::Base

  PROP_TYPES = %w(string number null)

  has_and_belongs_to_many :categories
  belongs_to :unit

  attr_reader :category_id, :upperd

  validates :prop_type, inclusion: { in: PROP_TYPES,
    message: "'%{value}' 不是一个有效的属性值类型" }

  validates :name, format: { with: /\A[a-z_][a-zA-Z_0-9]*\z/,
    message: "'%{value}' 不是一个有效的属性名称，必须是有效的Ruby变量名称" }

  validates :name, uniqueness: true

  def category_id
    read_attribute(:category_id)
  end

  def upperd?
    read_attribute(:upperd)
  end

  def inhibit?
    read_attribute(:state) == 1
  end

  def prop_types
    PROP_TYPES
  end
end
