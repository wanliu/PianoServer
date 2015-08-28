require 'active_resource'
class PromotionCollection < ActiveResource::Collection
  def initialize(parsed = {})
    @elements = parsed['promotions']
  end
end

class Promotion < ActiveResource::Base
  include Liquid::Rails::Droppable

  UPYUN_SITES = %r(neil-img.b0.upaiyun.com)

  self.site = Settings.wanliu.backend
  self.collection_parser = PromotionCollection

  def image_mobile_url
    UPYUN_SITES =~ image_url ? image_url + '!moblie': image_url
  end
end
