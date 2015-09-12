class StringProperty < Property::Base
  def initialize(config)
    super
  end

  def value
    @data['value']
  end

  def value=(value)
    @date = (@data || {})
    @data['value'] = value
  end
end
