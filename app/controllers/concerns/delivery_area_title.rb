module DeliveryAreaTitle
  private

  def get_code_title(code)
    if "default" == code
      "默认"
    else
      title = ChinaCity.get(code)

      unless code == ChinaCity.city(code)
        title = ChinaCity.get(ChinaCity.city(code)) + title
      end

      unless code == ChinaCity.province(code)
        title = ChinaCity.get(ChinaCity.province(code)) + title
      end

      title
    end
  end
end