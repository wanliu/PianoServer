class SalesMan < ActiveRecord::Base
  belongs_to :user
  belongs_to :shop

  delegate :avatar_url, :username, :nickname, to: :user
end
