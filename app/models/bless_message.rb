class BlessMessage < ActiveRecord::Base
  belongs_to :sender, class_name: 'User'
  belongs_to :bless

  validates :message, presence: true

  def party_owner_id
    birthday_party.try(:user_id)
  end

  def sender_avatar
    sender.try(:avatar_url)
  end

  def sender_username
    sender.try(:nickname)
  end
end
