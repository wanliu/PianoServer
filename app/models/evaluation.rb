class Evaluation < ActiveRecord::Base
  belongs_to :evaluationable, polymorphic: true, autosave: false
  belongs_to :user
  belongs_to :order

  has_many :thumbs, as: :thumbable
  has_many :thumbers, through: :thumbs

  store_accessor :items, :good, :delivery, :customer_service

  attr_reader :pmo_grab_id

  delegate :title, :avatar_urls, :image_urls, :cover_urls, 
    to: :evaluationable, allow_nil: true

  validates :evaluationable, presence: true
  validates :user, presence: true
  validates :order, presence: true

  after_commit :set_order_evaluated, on: :create

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
    self.order = Order.find_by(pmo_grab_id: grab_id)
  end

  private

  def check_user
    if user_id != order.buyer_id
      errors.add(:user_id, "只有买家才可以发表评论")
    end
  end

  def set_order_evaluated
    if persisted?
      order.update_attribute('evaluated', true)
    end
  end
end
