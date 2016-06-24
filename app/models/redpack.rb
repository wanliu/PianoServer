require "wx_redpack"

class Redpack < ActiveRecord::Base

  include WxRedpack

  belongs_to :user
  belongs_to :birthday_party

  validates :user, presence: true
  validates :birthday_party, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 1 }
  # validates :wx_order_no, presence: true

  after_commit :set_wx_order_no, on: :create

  # TODO async using sidekiq
  def send_pack
    if wx_user_openid.present?
      response = super

      if response.success?
        update_attribute("sent", true)
      end

      response.success?
    else
      false
    end
  end

  private

  def set_wx_order_no
    if persisted?
      udpate_attribute('wx_order_no', "1#{id.to_s.rjust(9, '0')}")
    end
  end
end
