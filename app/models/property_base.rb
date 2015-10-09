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

  def target
    @record.properties_target ||= {}
  end

  def type
  end

  def typecast(value)
    value
  end
end
