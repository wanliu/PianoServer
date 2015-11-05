class StringProperty < PropertyBase
  def initialize(*args)
    super
  end

  def typecast(value)
    value.to_s
  end
end
