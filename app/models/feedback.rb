class Feedback < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  paginates_per 10
  validates_presence_of :name, :information

end
