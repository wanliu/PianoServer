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

  validate :free_bless_limit, on: :create

  before_validation :copy_virtual_present_infor, on: :create
  after_commit :update_birthday_party_withdrawable, on: :create

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

  def free_bless_limit
    if 0 == virtual_present.price && reach_free_limit?
      errors.add(:base, "免费的礼物的配额已经使用！")
    end
  end

  def reach_free_limit?
    limit = (Settings.virtual_presents && Settings.virtual_presents.free_limit) || 1
    sender.blesses
      .where("birthday_party_id = ? AND virtual_present_infor @> ?", birthday_party_id, self.class.free_hearts_hash.to_json)
      .count >= limit
  end

  def update_birthday_party_withdrawable
    if persisted?
      birthday_party.update_withdrawable
    end
  end
end
