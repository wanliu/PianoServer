class DateTimeProperty < PropertyBase

  def typecast(value)
    DateTime.parse(value)
  end
end
