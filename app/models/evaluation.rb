class Evaluation < ActiveRecord::Base
  belongs_to :evaluationable, polymorphic: true
  belongs_to :user
  belongs_to :order, autosave: true

  store_accessor :items, :good, :delivery, :customer_service

  attr_reader :pmo_grab_id

  delegate :title, :avatar_urls, :image_urls, :cover_urls, 
    to: :evaluationable, allow_nil: true

  validates :evaluationable, presence: true
  validates :user, presence: true
  validates :order, presence: true

  before_create :set_order_evaluated

  validate :check_user

  def evaluationable
    if 'PmoItem' == evaluationable_type
      PmoItem[evaluationable_id]
    else
      super
    end
  end

  def evaluationable=(evalu)
    if PmoItem === evalu
      self.evaluationable_type = "PmoItem"
      self.evaluationable_id = evalu.id
    else
      super
    end
  end

  def pmo_grab_id=(grab_id)
    pmo_grab = PmoGrab[grab_id]
    self.evaluationable = pmo_grab.pmo_item
    self.order = Order.find(pmo_grab_id: grab_id)
  end

  private

  def check_user
    unless user_id != order.buyer_id
      errors.add(:user_id, "只有买家才可以发表评论")
    end
  end

  def set_order_evaluated
    order.evaluated = true
  end
end
