class Status < ActiveRecord::Base
  belongs_to :stateable, polymorphic: true

  enum state: [ :pending, :done ]

end
