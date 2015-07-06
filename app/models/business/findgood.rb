class Business::Findgood < Business::Base
  include ActionView::Helpers::AssetUrlHelper

  attr_reader :client_script

  def client_script
  	@client_script ||= asset_path('javascripts/business/clients/findgood.js');
  end
end