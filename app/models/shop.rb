require 'active_resource'
require 'active_support/json'

module ShopJsonFormat
  include ActiveResource::Formats::JsonFormat
  extend self

  def decode(_json)
    json = ActiveSupport::JSON.decode(_json)
    shop_json = json["shop"]
    shop_json.merge! "image" => json["images"][0]
    shop_json.merge! "owner" => json["users"][0]
    shop_json
  end
end

class Shop < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.format = ShopJsonFormat

  has_one :user

  def chats
    Chat.where('chatable_type = ? and chatable_id = ?', self.class.name, id)
  end

  def avatar_url
    image.try(:src)
  end
end
