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

  # new property did not set a type yet, so all the exteriors should be list
  def self.exteriors 
    {
      "日期选择器" => "date_picker",
      "传统模式" => "date_select",
      "样版选择器" => "swatch_select",
      "文本卡片" => "label_select",
      "下拉列表" => "dropdown"
    }
  end
end
