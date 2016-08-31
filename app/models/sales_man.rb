class SalesMan < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  has_many :temp_birthday_parties

  delegate :avatar_url, :username, :nickname, to: :user
end
