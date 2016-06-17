class BirthdayParty < ActiveRecord::Base
  belongs_to :cake
  belongs_to :user
  belongs_to :order
end
