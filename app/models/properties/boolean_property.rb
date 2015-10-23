class BooleanProperty < PropertyBase
  def initialize(*args)
    super
  end

  def typecast(value)
    "true" == value || "1" == value || true == value
  end
end
