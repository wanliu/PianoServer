####################
# 收件人信息 Model #
####################
class Location < ActiveRecord::Base
  belongs_to :user

  validates :contact, presence: true, length: { maximum: 30 }
  validates :road, presence: true,       length: { maximum: 140 }
  validates :contact_phone, presence: true,        length: {  is: 11 }

  attr_accessor :chat_id
  attr_accessor :order_id

  def to_s
    %(#{contact}, #{province_name}#{city_name}#{region_name}#{road}, #{contact_phone})
  end

  def province_name
    ChinaCity.get(province_id.to_s)
  end

  def city_name
    ChinaCity.get(city_id.to_s)
  end

  def region_name
    ChinaCity.get(region_id.to_s)
  end

  def full_address
    to_s  
  end
end
