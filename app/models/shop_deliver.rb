class ShopDeliver < ActiveRecord::Base
  belongs_to :shop
  belongs_to :deliver, class_name: 'User'

  validates :shop, presence: true
  validates :deliver, presence: true

  validates :deliver_id, uniqueness: {
    scope: [:shop_id],
    message: "该人员已经添加过，无需再次添加" }

  delegate :avatar_url, :username, :nickname, to: :deliver
end