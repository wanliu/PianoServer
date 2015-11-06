class IntegerProperty < PropertyBase
  def initialize(*args)
    super
  end

  def typecast(value)
    value.to_i
  end
end
