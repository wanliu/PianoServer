class DateTimeProperty < PropertyBase

  def value
    super.is_a?(String) ? typecast(super) : super
  end

  def typecast(value)
    if value.nil?
      nil
    else
      DateTime.parse(value)
    end
  end

  def self.exteriors
    { "日期选择器" => "date_picker", "传统模式" => "date_select" }
  end
end
