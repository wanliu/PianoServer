class DateTimeProperty < PropertyBase

  def value
    _value = super
    if _value.is_a? String
      typecast(super)
    else
      _value
    end
  end

  def typecast(value)
    value.blank? ? nil : DateTime.parse(value)
  end

  def self.exteriors
    { "日期选择器" => "date_picker", "传统模式" => "date_select" }
  end
end
