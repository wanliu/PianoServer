require 'active_resource'
require 'active_support/json'

module ShopJsonFormat
  include ActiveResource::Formats::JsonFormat
  extend self

  def decode(json)
    ActiveSupport::JSON.decode(json)["shop"]
  end
end


class Shop < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.format = ShopJsonFormat
end
