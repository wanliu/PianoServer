class Industry < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  enum status: [ :open, :close ]
  mount_uploader :image, ImageUploader

end
