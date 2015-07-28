class Chat < ActiveRecord::Base
  belongs_to :chatable, polymorphic: true
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
    owner_id and 0 < owner_id ? User.anonymous(owner_id) : super
  end

  def target
    target_id and 0 < target_id ? User.anonymous(target_id) : super
  end

  def chatable
    chatable_type == 'Shop' ? Shop.find(chatable_id) : super
  end
end
