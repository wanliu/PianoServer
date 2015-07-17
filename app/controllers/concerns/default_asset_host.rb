module DefaultAssetHost
  extend ActiveSupport::Concern

  included do 
    before_action :_default_asset_host
  end

  def _default_asset_host
    Thread.current[:default_asset_host] = 
      if Rails.application.config.action_controller.asset_path || Settings.asset_path
        Rails.application.config.action_controller.asset_path || Settings.asset_path
      elsif request.host == 'localhost' or  request.host == '127.0.0.1'
        require 'socket'
        ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
        ipaddress = ip.ip_address if ip
        if ipaddress
          "#{request.protocol}#{ipaddress}:#{request.port}"
        else
          "/"
        end
      else
        "#{request.protocol}#{request.host_with_port}"
      end
  end  
end
