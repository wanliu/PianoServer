class CouponTimeDuration
  ATTRS = {
    year: { name: "年" }, 
    month: { name: "月", max: 12 }, 
    # day: { name: "日", max: 31 },
    day: { name: "日" },
    hour: { name: "时", max: 24 },
    min: { name: "分", max: 60 },
    sec: { name: "秒", max: 60 }
  }

  ATTR_NAMES = ATTRS.keys
  attr_accessor *ATTR_NAMES

  attr_accessor :errors

  # 1/2/3/4/5/6 => 一年两个月三天四个小时五分六秒
  def initialize(duration)
    duration ||= {}

    @origin_duration = duration.symbolize_keys

    ATTR_NAMES.each do |attr|
      instance_variable_set("@#{attr}", (@origin_duration[attr] || 0).to_i)
    end
  end

  def validate
    self.errors ||= []
    validate_mins
    vaidate_maxs

    errors.length == 0
  end
  alias validate? validate

  def to_h
    { year: year, month: month, day: day, hour: hour, min: min, sec: sec }
  end

  def duration
    year.years + month.months + day.days + hour.hours + min.minutes + sec.seconds
  end

  private

  def validate_mins
    invalid_attrs = ATTR_NAMES.find_all do |attr|
      send(attr.to_sym) < 0
    end

    errors.concat invalid_attrs.map { |attr| "#{ATTRS[attr][:name]}的值不能小于零" }
  end

  def vaidate_maxs
    invalid_attrs = ATTR_NAMES.find_all do |attr|
      max = ATTRS[attr][:max]
      max.present? && send(attr.to_sym) >= max
    end

    errors.concat invalid_attrs.map { |attr| "#{ATTRS[attr][:name]}的值不能大于或等于#{ATTRS[attr][:max]}" }
  end
end