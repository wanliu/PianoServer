class SalesMan < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  has_many :temp_birthday_parties

  validates :user, presence: true
  validates :shop, presence: true
  validates :user_id, uniqueness: { scope: [:shop_id] }

  delegate :avatar_url, :username, :nickname, to: :user

  def phone
    attr_phone = super

    if attr_phone.present?
      attr_phone
    else
      user.mobile
    end
  end
end
