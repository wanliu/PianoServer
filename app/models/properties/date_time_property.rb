class DateTimeProperty < PropertyBase

  def value
    typecast(super)
  end

  def typecast(value)
    DateTime.parse(value)
  end

  def self.exteriors
    { "日期选择器" => "date_picker", "传统模式" => "date_select" }
  end
end
