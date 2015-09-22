class Shops::Admin::SettingsController < Shops::Admin::BaseController

  def index
    @settings = OpenStruct.new @shop.settings
  end


  def create
    key   = setting_params.keys[0]
    value = setting_params[key]
    @shop.update_attribute(key, value)
    render nothing: true
  end

  private

  def setting_params
    params.require(:setting)
  end
end
