####################
# 收件人信息 Model #
####################
class Location < ActiveRecord::Base
  belongs_to :user

  VALID_PHONE_REGEX = /\A((\d{3,4}-\d{7,8}(-\d+)?)|((\+?86)?1\d{10}))\z/
  VALID_CONTACT_REGEX = /([\u4e00-\u9fa5]|[a-zA-Z0-9_]|[\uFF10-\uFF19])+/

  validates :contact, presence: true, length: { maximum: 30 }, format: { with: VALID_CONTACT_REGEX, :allow_blank => true }, on: :create
  validates :road, presence: true, length: { maximum: 140 }, on: :create
  validates :contact_phone, presence: true, format: { with: VALID_PHONE_REGEX, :allow_blank => true }, on: :create
  validates :province_id, presence: true, on: :create
  validates :city_id, presence: true, on: :create
  validates :region_id, presence: true, on: :create

  validate :too_many_record

  attr_accessor :chat_id, :intention_id

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

  def delivery_address
    %(#{province_name}#{city_name}#{region_name}#{road} #{contact_phone})
  end

  def too_many_record
    locations = user.locations

    if locations.length >= 5
      errors.add(:amount, '已达到上限')
    end
  end
end
