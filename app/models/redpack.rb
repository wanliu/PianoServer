require "wx_redpack"

class Redpack < ActiveRecord::Base

  include WxRedpack

  belongs_to :user
  belongs_to :birthday_party

  validates :user, presence: true
  validates :birthday_party, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 1 }
  validates :wx_order_no, presence: true

  before_validation :set_wx_order_no

  def wx_order_no
    super || "1#{id.to_s.rjust(9, '0')}"
  end

  private

  def set_wx_order_no
    self.wx_order_no = wx_order_no if [:wx_order_no].blank?
  end
end
