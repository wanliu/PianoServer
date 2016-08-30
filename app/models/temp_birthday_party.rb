class TempBirthdayParty < ActiveRecord::Base
  belongs_to :cake
  belongs_to :user
  belongs_to :sales_man
end
