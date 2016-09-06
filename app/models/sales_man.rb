class SalesMan < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  has_many :temp_birthday_parties

  validates :user, presence: true
  validates :shop, presence: true
  validates :user_id, uniqueness: { scope: [:shop_id] }

  delegate :avatar_url, :username, :nickname, to: :user
end
