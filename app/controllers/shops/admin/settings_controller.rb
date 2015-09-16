class Shops::Admin::SettingsController < Shops::Admin::BaseController

  def index
    @settings = @shop.settings
  end
end
