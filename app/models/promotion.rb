require 'active_resource'
class PromotionCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['promotions']
  end
end

class Promotion < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.collection_parser = PromotionCollection

  def image_mobile_url
    image_url + '!moblie'
  end
end
