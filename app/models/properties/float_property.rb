class FloatProperty < PropertyBase
  def initialize(*args)
    super
  end

  def typecast(value)
    value.to_f
  end
end
