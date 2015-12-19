module ColorLabelHelper
  cattr_accessor :color_list

  def color_label(label,  color)
    content_tag :span, label, class: 'label', style: "background-color: #{color}"
  end

  def color_label_with_name(label)
    index = Zlib.crc32(label) % color_list.count
    color_label label, color_list[index]
  end
end

ColorLabelHelper.color_list ||= YAML.load_file(Rails.root.join('config/colors.yml')).map { |k, v| v }
