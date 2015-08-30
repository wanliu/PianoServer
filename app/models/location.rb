####################
# 收件人信息 Model #
####################
class Location < ActiveRecord::Base
  belongs_to :user

  VALID_PHONE_REGEX = /((\d{3,4}-\d{7,8}(-\d+)?)|((\+?86)?1\d{10}))/

  validates :contact, presence: true, length: { maximum: 30 }, on: :create
  validates :road, presence: true, length: { maximum: 140 }, on: :create
  validates :contact_phone, presence: true, format: { with: VALID_PHONE_REGEX, :allow_blank => true }, on: :create
  validates :province_id, presence: true, on: :create
  validates :city_id, presence: true, on: :create
  validates :region_id, presence: true, on: :create

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
