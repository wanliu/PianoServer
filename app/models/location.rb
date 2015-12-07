####################
# 收件人信息 Model #
####################
class Location < ActiveRecord::Base
  belongs_to :user

  AMOUNT_LIMIT = 4

  VALID_PHONE_REGEX = /\A((\d{3,4}-\d{7,8}(-\d+)?)|((\+?86)?1\d{10}))\z/
  VALID_CONTACT_REGEX = /([\u4e00-\u9fa5]|[a-zA-Z0-9_]|[\uFF10-\uFF19])+/

  validates :contact, presence: true,
    length: { maximum: 30 },
    format: { with: VALID_CONTACT_REGEX, :allow_blank => true },
    unless: :skip_validation

  validates :contact_phone, presence: true,
    format: { with: VALID_PHONE_REGEX, :allow_blank => true },
    unless: :skip_validation

  validates :road, presence: true,
    length: { maximum: 140 },
    unless: :skip_validation

  validates :province_id, presence: true
  validates :city_id, presence: true
  validates :region_id, presence: true

  validate :too_many_record, unless: :skip_validation

  belongs_to :region, foreign_key: :region_id, primary_key: :city_id

  attr_accessor :chat_id, :intention_id
  attr_accessor :skip_validation

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
    locations = user.try(:locations) || []

    if locations.length > AMOUNT_LIMIT
      errors.add(:amount, '已达到上限')
    end
  end

  def is_default?
    id == user.latest_location_id
  end
end
