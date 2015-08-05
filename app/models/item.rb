require 'active_resource'

class ItemCollection < ActiveResource::Collection
  include ActiveResource::Formats::JsonFormat
  # extend self

  scope :last_iid, -> (target) do
    where(itemable: target).order(:iid).last.try(:iid) || 0
  end

  def decode(_json)
    json = ActiveSupport::JSON.decode(_json)
    shop_json = json["items"]
    shop_json
  end

  def sub_total
    super.nil? ? calc_sub_total : super
  end

  def calc_sub_total
    price * amount
  end
end

class Item < ActiveResource::Base
  self.site = Settings.wanliu.backend
  self.collection_parser = ItemCollection
end
