class NumberProperty < PropertyBase
  def initialize(*args)
    super
  end

  def typecast(value)
    value.to_d
  end
end
