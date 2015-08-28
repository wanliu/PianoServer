class Attachment < ActiveRecord::Base
  include Liquid::Rails::Droppable

  belongs_to :attachable, polymorphic: true

  mount_uploader :filename, ImageUploader
end
