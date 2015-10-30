class Feedback < ActiveRecord::Base
  validates_presence_of :name, :mobile, :information
end
