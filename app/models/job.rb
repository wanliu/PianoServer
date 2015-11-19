class Job < ActiveRecord::Base
  belongs_to :jobable, polymorphic: true

end
