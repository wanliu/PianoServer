class BirthdayParty < ActiveRecord::Base
  belongs_to :cake
  belongs_to :user
  belongs_to :order

  has_many :blesses

  validates :cake, presence: true
  validates :user, presence: true
  validates :order, presence: true
  validates :message, presence: true
  validates :birthday_person, presence: true
end
