class Industry < ActiveRecord::Base
  enum status: [ :open, :close ]

end
