class Evaluation < ActiveRecord::Base
  belongs_to :evaluationable, polymorphic: true, autosave: false
  belongs_to :user
  belongs_to :order

  has_many :thumbs, as: :thumbable
  has_many :thumbers, through: :thumbs

  has_many :favoritors, as: :favoritable, class_name: 'Favorite'

  store_accessor :items, :good, :delivery, :customer_service

  attr_reader :pmo_grab_id

  delegate :title, :avatar_urls, :image_urls, :cover_urls, 
    to: :evaluationable, allow_nil: true

  validates :user, presence: true
  validates :order, presence: true
  validates :good, presence: true
  validates :delivery, presence: true
  validates :customer_service, presence: true

  validates :evaluationable, presence: true, 
    unless: Proc.new { |ee| "Promotion" == ee.evaluationable_type }

  validates :user_id, uniqueness: {
    scope: [:order_id, :evaluationable_type, :evaluationable_id],
    message: "你已经评论过了！"
  }

  validate :check_user

  def evaluationable
    if 'PmoItem' == evaluationable_type
      PmoItem[evaluationable_id]
    elsif "Promotion" == evaluationable_type
      Promotion.find(evaluationable_id)
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
end
