class Chat < ActiveRecord::Base
  belongs_to :roomable
  belongs_to :owner, class_name: 'User'
  belongs_to :target, class_name: 'User'
  has_many :messages, as: :messable

  store_accessor :data, :order_id

  scope :both, -> (owner_id, target_id) {
    where(owner_id: owner_id, target_id: target_id)
  }

  scope :in, -> (id) {
    where("owner_id = ? or target_id = ?", id, id).order(:updated_at)
  }

  def owner
    owner_id < 0 ? User.anonymous(owner_id) : super
  end

  def target
    target_id < 0 ? User.anonymous(target_id) : super
  end

end
