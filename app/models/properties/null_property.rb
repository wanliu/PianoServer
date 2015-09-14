class NullProperty < PropertyBase
  def initialize(name, record = nil, options = {})
    super

  end

  def value
    nil
  end

  def value=(value)
    # ignore
  end
end
