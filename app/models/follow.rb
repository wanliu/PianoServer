class Follow < ActiveRecord::Base
  belongs_to :follower, polymorphic: true
  belongs_to :followable, polymorphic: true
end
