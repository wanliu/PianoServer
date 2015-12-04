class PropertyBase

  def initialize(name, record, config)
    @property_name = name
    @name = config["name"]
    @title = config["title"]
    @type = config["type"]
    @record = record
  end

  def value
    field = target[@name] || {}
    field["value"]
  end

  def value=(value)
    field = target[@name] ||= {}
    field["value"] = typecast(value)
  end

  def title=(title)
    field = target[@name] ||= {}
    field["title"] = title
  end

  def exterior=(exterior)
    field = target[@name] ||= {}
    field["exterior"] = exterior
  end

  def prop_type=(prop_type)
    field = target[@name] ||= {}
    field["prop_type"] = prop_type
  end

  def target
    @record.properties_target ||= {}
  end

  def type
  end

  def typecast(value)
    value
  end

  def self.exteriors
    {}
  end
end
