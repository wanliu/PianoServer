module DynamicProperty
  HashEx = ActiveSupport::HashWithIndifferentAccess

  extend ActiveSupport::Concern

  attr_accessor :property_delagates

  def method_missing(method, *args)
    name = method.to_s
    super unless name.start_with?('property_')
    property_name = name[9..-1]
    if property_name.end_with?('=')
      write_property(property_name[0..-2], *args)
    else
      read_property(property_name, *args)
    end
  end

  def write_property(name, value)
    property = property_config_with_properties(name)
    property.value = value
  end

  def read_property(name)
    property = property_config_with_properties(name)
    property.value
  end

  def property_delagates
    @property_delagates ||= HashEx.new
  end

  def properties_target
    case self.class.dynamic_property_target
    when Symbol, String
      send(self.class.dynamic_property_target)
    when Proc
      self.class.dynamic_property_target.call(self)
    else
      raise StandardError.new "Not defined a correct dynamic_property target with `dynamic_property` class method."
    end
  end

  private

  def property_config(name, config)
    prefix_name = "#{properties_prefix}_#{name}"
    _config = config.merge "name" => name

    property_delagates[name] ||=
      case config["type"]
      when "string"
        StringProperty.new prefix_name, self, _config
      when "number"
        NumberProperty.new prefix_name, self, _config
      when "integer"
        IntegerProperty.new prefix_name, self, _config
      when "float"
        FloatProperty.new prefix_name, self, _config
      when "boolean"
        BooleanProperty.new prefix_name, self, _config
      when "map"
        MapProperty.new prefix_name, self, _config
      else
        NullProperty.new prefix_name, self, _config
      end
  end

  def property_config_with_properties(name)
    config = (definition_properties || {})[name]

    if config.nil?
      NullProperty.new "#{properties_prefix}_#{name}"
    else
      property_config(name, config)
    end
  end

  def properties_prefix
    self.class.dynamic_property_options[:prefix]
  end

  module ClassMethods
    attr_accessor :dynamic_property_options
    attr_accessor :dynamic_property_target

    def dynamic_property(target, options = {})
      @dynamic_property_options = options
      @dynamic_property_target = target
    end

    def dynamic_property_options
      @dynamic_property_options ||= {prefix: 'property'}
    end

    def dynamic_property_target
      @dynamic_property_target ||= :properties
    end
  end
end
