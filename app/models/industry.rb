class Industry < ActiveRecord::Base
  enum status: [ :open, :close ]
  mount_uploader :image, ImageUploader

end
