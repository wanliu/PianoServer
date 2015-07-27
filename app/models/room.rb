class Room < ActiveRecord::Base
  belongs_to :roomable
  belongs_to :owner, class_name: 'User'
  belongs_to :target, class_name: 'User'
  has_many :messages, as: :messable

  store_accessor :data, :order_id

  scope :both, -> (owner_id, target_id) {
    where(owner_id: owner_id, target_id: target_id)
  }

end
