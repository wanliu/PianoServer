class ConsumedCardCode < ActiveRecord::Base
  belongs_to :user
  belongs_to :order

  validates :user, presence: true
  validates :code, presence: true
  validates :wx_card_id, presence: true
end
