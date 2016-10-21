require "wx_redpack"

class Redpack < ActiveRecord::Base

  include WxRedpack

  # SENDING:发放中, SENT:已发放待领取, FAILED：发放失败, RECEIVED:已领取, REFUND:已退款
  enum status: { unknown: 0, sending: 1, sent: 2, failed: 3, received: 4, refound: 5 }
  STATUS_TITLE = {
    "unknown" => "未发放",
    "sending" => "发放中",
    "sent" => "已发放",
    "failed" => "发放失败",
    "received" => "已领取",
    "refound" => "已退款"
  }

  belongs_to :user
  belongs_to :birthday_party

  validates :user, presence: true
  validates :birthday_party, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 1 }
  # validates :wx_order_no, presence: true

  # after_commit :set_wx_order_no, on: :create

  # TODO async using sidekiq
  def send_redpack
    response = super

    if response.success? && !sent?
      update_columns(status: self.class.statuses["sent"], error_message: nil)
    end

    unless response.success?
      if "该订单已经过期,请更换商户单号" == response.error_message
        update_columns("error_message" => "该订单已经过期,已经更改订单号,请再次发送该红包", "status" => self.class.statuses["failed"], "wx_expired_at" => Date.today)
      else
        update_columns("error_message" => response.error_message, "status" => self.class.statuses["failed"])
      end
    end

    response
  end

  def query_redpack
    response = super

    if response.success?
      update_column("status", self.class.statuses[response.status.downcase])
    end

    response
  end

  # 红包单号最后10位数子以1开头，以便与订单相区分
  def wx_order_no
    "1#{id.to_s.rjust(9, '0')}"
  end

  def status_title
    STATUS_TITLE[status]
  end

  private

  # def set_wx_order_no
  #   if persisted?
  #     update_attribute('wx_order_no', "1#{id.to_s.rjust(9, '0')}")
  #   end
  # end
end
