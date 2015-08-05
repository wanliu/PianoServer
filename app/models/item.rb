require 'active_resource'

class ItemCollection < ActiveResource::Collection
  include ActiveResource::Formats::JsonFormat
  # extend self

  def decode(_json)
    json = ActiveSupport::JSON.decode(_json)
    shop_json = json["items"]
    shop_json
  end
end

class Item < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.collection_parser = ItemCollection
end
