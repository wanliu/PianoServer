module DebugMode
  extend ActiveSupport::Concern

  if Rails.env.development?
    included do 
      before_action :_enable_debug
    end

    def _enable_debug
      Settings.debug = params[:debug]
    end
  end
end
