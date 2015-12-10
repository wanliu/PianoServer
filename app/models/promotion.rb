require 'active_resource'
class PromotionCollection < ActiveResource::Collection
  include Liquid::Rails::Droppable

  def initialize(parsed = {})
    @elements = parsed['promotions']
  end

  def drop_class
    "PromotionDrop".safe_constantize
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

  def self.punch(punchable, request=nil)
    if request.try(:bot?)
      false
    else
      p = Punch.new
      p.punchable_type = "Promotion"
      p.punchable_id = punchable.id
      p.save ? p : false
    end
  end

  def hits(since=nil)
    punches.after(since).sum(:hits)
  end

  def punch(request=nil)
    self.class.punch(self, request)
  end

  def punches
    Punch.where("punchable_type = ? and punchable_id = ?", "Promotion", self.id)
  end

  def shop
    Shop.where(id: shop_id).first
  end

  def deduct_stocks!(operator, options)
    source = options[:source]

    WanliuLineItem.create(
      promotion_id: id,
      line_item_type: source.class.to_s,
      line_item_id: source.id,
      quantity: options[:quantity],
      status: 1)
  end

  def saleable?(amount=1, props={})
    unless 'Active' == status
      yield false, false, 0 if block_given?
      return false
    end

    yield true, product_inventory >= amount, product_inventory if block_given?
    product_inventory >= amount
  end
end
