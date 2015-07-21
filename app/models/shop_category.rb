require 'active_resource'
require 'active_support/json'

module ShopCategoryJsonFormat
  include ActiveResource::Formats::JsonFormat
  extend self

  def decode(_json)
    json = ActiveSupport::JSON.decode(_json)
    shop_json = json["shop_categories"]
    shop_json
  end
end

class ShopCategory < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.format = ShopCategoryJsonFormat
end
