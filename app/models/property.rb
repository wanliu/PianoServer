class Property < ActiveRecord::Base
  include ContentManagement::Model

  DATA_KEY_MAP = "map"
  DATA_KEY_GROUP = "group"
  DATA_KEY_DEFAULT = "default_value"
  DATA_KEY_VALIDATE = "validate_rules"

  MAP_TYPES = %w(map sale_map stock_map)
  PROP_TYPES = %w(string integer number float date boolean) + MAP_TYPES

  VALIDATE_MELPERS = %w(acceptance confirmation exclusion format inclusion length numericality presence absence uniqueness)

  store_accessor :data, :exterior

  has_and_belongs_to_many :categories
  belongs_to :unit

  attr_reader :category_id, :upperd

  validates :prop_type, inclusion: { in: PROP_TYPES,
    message: "'%{value}' 不是一个有效的属性值类型" }

  validates :name, format: { with: /\A[a-z_][a-zA-Z_0-9]*\z/,
    message: "'%{value}' 不是一个有效的属性名称，必须是有效的Ruby变量名称" }

  validates :name, uniqueness: true

  validate :validate_rules_json_format

  def self.map_type?(type)
    MAP_TYPES.include? type
  end

  def map_type?
    self.class.map_type? prop_type
  end

  def map_pairs
    map_data = data || {}
    map_data[DATA_KEY_MAP] || {}
  end

  def title_of(value)
    map_pairs[value]
  end

  # FROM: "map_pairs"=>{"keys"=>{"0"=>"a"}, "values"=>{"0"=>"2"}}}
  # TO:   data: { map : {"a": "2"}}
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

  def is_group
    jsonb_data = data || {}
    jsonb_data[DATA_KEY_GROUP] == true
  end

  def is_group=(value)
    self.data ||= {}

    if "true" == value
      self.data[DATA_KEY_GROUP] = true
    elsif "false" == value
      self.data[DATA_KEY_GROUP] = false
    end
  end

  def default_value
    jsonb_data = data || {}
    jsonb_data[DATA_KEY_DEFAULT]
  end

  def default_value=(value)
    return if value.blank?

    self.data ||= {}
    self.data[DATA_KEY_DEFAULT] = value
  end

  def validate_rules
    jsonb_data = data || {}
    jsonb_data[DATA_KEY_VALIDATE]
  end

  def validate_rules=(rules)
    return if rules.blank?

    # rules = rules.first(250)

    begin
      valid_rules = JSON.parse(rules)
    rescue JSON::ParserError => e
      valid_rules = rules
    end

    self.data ||= {}
    self.data[DATA_KEY_VALIDATE] = valid_rules
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

  def exteriors
    prop_class.exteriors || []
  end

  def prop_class
    case prop_type
    when "string"
      StringProperty
    when "number"
      NumberProperty
    when "integer"
      IntegerProperty
    when "float"
      FloatProperty
    when "boolean"
      BooleanProperty
    when "map", "stock_map", "sale_map"
      MapProperty
    when "date", "datetime"
      DateTimeProperty
    else
      NullProperty
    end
  end

  protected
    def validate_rules_json_format
      return if validate_rules.blank?

      unless validate_rules.is_a? Hash
        errors.add(:validate_rules, "格式不正确，必须是有效的json数据格式并且长度不能超过250个字符")
        return
      end

      validate_rules.keys.each do |validator|
        unless VALIDATE_MELPERS.include? validator
          errors.add(:validate_rules, "'#{validator}'为无效验证方法")
        end
      end
    end
end
