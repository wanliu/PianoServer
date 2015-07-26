require 'active_resource'
require 'active_support/json'

class WanliuUserCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['users']
  end
end

module WanliuUserJsonFormat
  include ActiveResource::Formats::JsonFormat
  extend self

  def decode(_json)
    json = ActiveSupport::JSON.decode(_json)
    user_json = json["user"]
    user_json.merge! "image" => json["images"][0]
    user_json
  end
end

class WanliuUser < ActiveResource::Base
	self.site = Settings.wanliu.backend
	self.element_name = 'users'
  self.collection_parser = WanliuUserCollection
  # self.format = WanliuUserJsonFormat
end
