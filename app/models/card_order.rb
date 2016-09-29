class CardOrder < ActiveRecord::Base
  include WxOrder

  belongs_to :item
  belongs_to :user

  # validates :item, presence: true
  # validates :wx_card_id, presence: true
  # validates :title, presence: true
  # validates :pmo_grab_id, uniqueness: true

  def wx_order_notify_url
    "#{Settings.app.website}/card_orders/#{id}/wx_notify"
  end

  def wx_total_fee
    price
  end

  def withdrew_card
    update_column('withdrew', true)

    if pmo_grab_id.present?
      pmo_grab = PmoGrab[pmo_grab_id]
      pmo_grab.ensure! if pmo_grab.present?
    end
  end
end
