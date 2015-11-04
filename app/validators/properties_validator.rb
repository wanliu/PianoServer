# PropertiesValidator 属性集合验证器，基于一个 json 字段的表达，验证所有的附加属性值的有效性
#
# 原理
#    依照一个动态属性的定义(properties_definitions)表列，自动生成一组不同类型的验证功能
#
# class Item < ActiveRecord::Base
#
#   validates :properties, properties: {
#     accessor_prefix: 'property',
#     definitions: :properties_definitions }
#
# 依赖：动态属性绑定特性
#
class PropertiesValidator < ActiveModel::EachValidator
  VALIDATOR_TYPES = %w(absence acceptance callbacks clusivity confirmation exclusion
    format inclusion length numericality presence)

  def initialize(options)
    @method_prefix = options.delete(:accessor_prefix) || 'property'
    @definitions = options.delete(:definitions) || {}
    super
  end

  def validate_each(record, attribute, value)
    validates_config_of(record, attribute) do |type, options|
      if type
        validator = method_of_validator(type).call(attribute, options)
        validator.validate_each record, attribute, value
      end
    end
  end

  def validate(record) #:no-rdoc
    attributes.each do |attribute|
      properties = record.read_attribute_for_validation(attribute)
      next if (properties.nil? && options[:allow_nil]) || (properties.blank? && options[:allow_blank])
      properties.each do |name, config|
        property_name = "#{@method_prefix}_#{name}"
        value = record.read_attribute_for_validation(property_name)
        validate_each(record, property_name, value)
      end
    end
  end

  # method_of_validator 不同验证类型方法的实体
  def method_of_validator(type, options = {})
    method("property_validate_of_#{type}")
  end

  # resolve_type_of_validator 返回属性类型的验证类型
  def resolve_type_of_validator(type)
    case type
    when "string"
      "presence"
    when "integer", "float", "number"
      "numericality"
    when "date", "datetime"
      "presence"
    when "map"
      "presence"
    when "boolean"
      nil
    else
      "presence"
    end
  end


  # validates_config_of 返回属性的验证定义
  def validates_config_of(record, attribute)
    record_definitions record do |definitions|
      remove_prefix_name = attribute.sub(/\A#{@method_prefix}_/, '')
      config = definitions[remove_prefix_name] || {}
      if config["validates"]
        config["validates"].each do |validate, options|
          yield validate, options == true ? {} : options.symbolize_keys
        end
      elsif config["type"]
        yield resolve_type_of_validator(config["type"]), {}
      end
    end
  end

  # record_definitions 获取 记录的 属性定义
  def record_definitions(record, &block)
    yield case @definitions
          when Symbol, String
            record.send(@definitions)
          when Proc
            @definitions.call(record)
          when Hash
            @definitions
          else
            raise StardardError.new("don't have a valid definitions settings")
          end
  end


  VALIDATOR_TYPES.each do |validate_type|
    self.class_eval <<-RUBY, __FILE__, __LINE__ + 1

      def property_validate_of_#{validate_type}(property, options = {})
        klass         = ActiveModel::Validations::#{validate_type.classify}Validator
        options       = { attributes: [ property ]}.merge(options)
        validator     = klass.new(options)
      end
    RUBY
  end
end
