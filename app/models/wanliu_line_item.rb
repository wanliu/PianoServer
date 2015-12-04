require 'active_resource'
require 'active_support/json'

# class WanliuLineItemCollection < ActiveResource::Collection
#   def initialize(parsed = {})
#     @elements = parsed['users']
#   end
# end

# module WanliuLineItemJsonFormat
#   include ActiveResource::Formats::JsonFormat
#   extend self

#   def decode(_json)
#     json = ActiveSupport::JSON.decode(_json)
#     user_json = json["user"]
#     user_json.merge! "image" => json["images"][0]
#     user_json
#   end
# end

class WanliuLineItem < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.element_name = 'piano_line_items'
  self.headers["Pry-Token"] = Settings.wanliu.pry_token
  # self.collection_parser = WanliuLineItemCollection
  # self.format = WanliuLineItemJsonFormat
end
