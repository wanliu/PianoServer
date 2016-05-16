class ExpressTemplate < ActiveRecord::Base
  belongs_to :shop

  has_many :applied_items, class_name: 'Item', dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :shop_id }
  validates :shop, presence: true

  validate :validate_template_format

  VALIDE_SETTING_KEYS = {
    "first_quantity" => "首件",
    "first_fee" => "首费",
    "next_quantity" => "续件",
    "next_fee" => "续费"
  }

  def apply(options)
    return 0 if free_shipping?

    if options[:to].blank?
      raise ArgumentError, "need \"to\" options as the target shipping area!"
    end

    quantity = options[:quantity].present? ? options[:quantity].to_i : 1

    area_code = options[:to].to_s
    city_code = ChinaCity.city(area_code)
    province_code = ChinaCity.province(area_code)

    setting = template[area_code] ||
      template[city_code] ||
      template[province_code] ||
      template["default"] || { first_quantity: 0, first_fee: 0 }

    first_quantity = setting["first_quantity"].to_i
    first_fee = setting["first_fee"].to_f

    next_quantity = setting["next_quantity"].to_i
    next_fee = setting["next_fee"].to_f

    if quantity <= first_quantity
      first_fee
    elsif next_quantity <= 0
      first_fee
    else
      first_fee + ((quantity - first_quantity)/next_quantity).ceil * next_fee
    end
  end

  private

  def validate_template_format
    defualt_should_not_empty
    check_quantity_and_fee_key_value
  end

  def defualt_should_not_empty
    if !free_shipping && default_empty?
      errors.add(:base, "默认运费不能为空")
    end
  end

  def default_empty?
    default = template["default"]
    default.blank? || default["first_quantity"].blank? || default["first_fee"].blank?
  end

  def check_quantity_and_fee_key_value
    template.each do |code, setting|
      if "default" != code && !(ChinaCity.get(code) rescue false)
        errors.add(:base, "无效的地区代码：#{code}")
      end

      setting.each do |setting_key, quantity_or_fee|
        quantity_or_fee = quantity_or_fee.to_i

        unless VALIDE_SETTING_KEYS.keys.include? setting_key
          errors.add(:base, "不正确的设置选项：#{setting_key}")
        end

        if quantity_or_fee < 0
          setting_key_name = VALIDE_SETTING_KEYS[setting_key]
          errors.add(:base, "#{ChinaCity.get(code, prepend_parent: true)}地区的运费 #{setting_key_name} 不能小于０")
        end
      end
    end
  end
end
