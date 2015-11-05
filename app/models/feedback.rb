class Feedback < ActiveRecord::Base

  paginates_per 10
  validates_presence_of :name, :information

end
