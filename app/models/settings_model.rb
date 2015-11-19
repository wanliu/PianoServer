class SettingsModel
  extend ActiveModel::Naming
  include Singleton

  attr_accessor :default_values

  def set_default(key, value)
    @default_values ||= ActiveSupport::HashWithIndifferentAccess.new
    @default_values[key] = value
  end

  private

  def method_missing(name, *args, &block)
    names = name.to_s.split('.')
    value = names.inject(Settings){ |s, name| s.nil? ? nil : s[name] }
    value.nil? ? default_values[name] : value
  rescue
    super
  end
end
