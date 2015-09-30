class Property < ActiveRecord::Base

  DATA_KEY_MAP = "map"
  DATA_KEY_GROUP = "group"
  DATA_KEY_DEFAULT = "default_value"
  DATA_KEY_VALIDATE = "validate_rules"

  PROP_TYPES = ["string", "number", "date", "boolean", DATA_KEY_MAP]

  VALIDATE_MELPERS = %w(acceptance confirmation exclusion format inclusion length numericality presence absence uniqueness)

  has_and_belongs_to_many :categories
  belongs_to :unit

  attr_reader :category_id, :upperd

  validates :prop_type, inclusion: { in: PROP_TYPES,
    message: "'%{value}' 不是一个有效的属性值类型" }

  validates :name, format: { with: /\A[a-z_][a-zA-Z_0-9]*\z/,
    message: "'%{value}' 不是一个有效的属性名称，必须是有效的Ruby变量名称" }

  validates :name, uniqueness: true

  validate :validate_rules_json_format

  def map_pairs
    map_data = data || {}
    map_data[DATA_KEY_MAP] || {}
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

    value = value.first(250)

    self.data ||= {}
    self.data[DATA_KEY_VALIDATE] = rules
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

  protected
    def validate_rules_json_format
      return if validate_rules.blank?

      begin
        rules = JSON.parse(validate_rules)

        rules.keys.each do |validator|
          unless VALIDATE_MELPERS.include? validator
            errors.add(:validate_rules, "'#{validator}'为无效验证方法")
          end
        end
      rescue JSON::ParserError => e
        errors.add(:validate_rules, "格式不正确，必须是有效的json数据格式并且长度不能超过250个字符")
      end
    end
end