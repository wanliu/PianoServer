class Message < ActiveRecord::Base
  belongs_to :messable
  belongs_to :image_ref, class_name: 'Message'
  belongs_to :from, class_name: 'User'
  belongs_to :reply, class_name: 'User'

  def image
    super || image_ref && image_ref.image
  end
end
