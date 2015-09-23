class Property < ActiveRecord::Base

  DATA_KEY_MAP = "map"

  PROP_TYPES = ["string", "number", "date", "boolean", DATA_KEY_MAP]

  has_and_belongs_to_many :categories
  belongs_to :unit

  attr_reader :category_id, :upperd

  validates :prop_type, inclusion: { in: PROP_TYPES,
    message: "'%{value}' 不是一个有效的属性值类型" }

  validates :name, format: { with: /\A[a-z_][a-zA-Z_0-9]*\z/,
    message: "'%{value}' 不是一个有效的属性名称，必须是有效的Ruby变量名称" }

  validates :name, uniqueness: true

  def map_pairs
    map_data = data || {}
    map_data[DATA_KEY_MAP] || {}
  end

  # "map_pairs"=>{"keys"=>{"0"=>"a"}, "values"=>{"0"=>"2"}}}
  def map_pairs=(hash)
    return if hash.blank?

    pairs = {}

    keys = hash["keys"]
    values = hash["values"]

    keys.keys.each do |k|
      key = keys[k]
      value = values[k]

      if key.present? && value.present?
        pairs[key] = value 
      end
    end

    self.data ||= {}
    self.data[DATA_KEY_MAP] = pairs
  end

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
