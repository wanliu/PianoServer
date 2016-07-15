require 'wx_order'
require 'weixin_api'

class Bless < ActiveRecord::Base

  include WxOrder

  scope :paid, -> { where(paid: true) }
  scope :free_hearts, -> { where("virtual_present_infor @> ?", Bless.free_hearts_hash.to_json) }
  scope :charged, -> { where.not("virtual_present_infor @> ?", Bless.free_hearts_hash.to_json) }

  belongs_to :virtual_present
  belongs_to :birthday_party
  belongs_to :sender, class_name: 'User'

  validates :birthday_party, presence: true
  validates :virtual_present, presence: true
  validates :sender, presence: true

  validate :only_one_free_bless, on: :create

  before_validation :copy_virtual_present_infor, on: :create

  class << self
    def free_hearts_hash
      {price: BigDecimal.new(0)}
    end
  end

  def wx_order_notify_url
    "#{Settings.app.website}/blesses/#{id}/wx_notify"
  end

  def wx_total_fee
    virtual_present_infor["price"].to_f
  end

  private

  def copy_virtual_present_infor
    self.virtual_present_infor = {
      id: virtual_present.id,
      name: virtual_present.name,
      title: virtual_present.title,
      price: virtual_present.price,
      value: virtual_present.value
    }
  end

  def only_one_free_bless
    if 0 == virtual_present.price && free_present_exist?
      errors.add(:base, "免费的礼物的配额已经使用！")
    end
  end

  def free_present_exist?
    sender.blesses
      .where("birthday_party_id = ? AND virtual_present_infor @> ?", birthday_party_id, self.class.free_hearts_hash.to_json)
      .exists?
  end
end
