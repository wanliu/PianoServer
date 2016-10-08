class Card < ActiveRecord::Base
  validates :wx_card_id, presence: true, uniqueness: true
  validates :title, presence: true, uniqueness: true

  enum kind: { 
    "GROUPON" => 0, 
    "DISCOUNT" => 1, 
    "GIFT" => 2, 
    "CASH" => 3, 
    "GENERAL_COUPON" => 4,
    "MEMBER_CARD" => 5
  }

  KIND_MAP = {
    "GROUPON" => "团购券",
    "DISCOUNT" => "折扣券",
    "GIFT" => "礼品券",
    "CASH" => "代金券",
    "GENERAL_COUPON" => "通用券",
    "MEMBER_CARD" => "会员卡"
  }

  class << self
    def refresh!
      card_list = Wechat.api.card_api_ticket.batch_get

      card_list.each do |card_id|
        card_info = Wechat.api.card_api_ticket.card_detail(card_id)
        card = find_by(wx_card_id: card_id)

        if card.present?
          card.update_from_card_info(card_info)
        else
          create_from_card_info(card_info)
        end
      end
    end

    def create_from_card_info(card_info)
      card_kind = card_info["card_type"]
      infors = card_info[card_kind.downcase].freeze

      if kinds.keys.include? card_kind
        options = card_info_params(infors).merge(
          kind: card_info["card_type"],
          wx_card_id: infors["base_info"]["id"]
        )

        create options
      end
    end

    def card_info_params(infors)
      {
        title: infors["base_info"]["title"],
        base_info: infors["base_info"],
        deal_detail: infors["deal_detail"],
        gift: infors["gift"],
        least_cost: infors["least_cost"],
        reduce_cost: infors["reduce_cost"],
        discount: infors["discount"]
      }
    end
  end

  def update_from_card_info(card_info)
    card_kind = card_info["card_type"]
    infors = card_info[card_kind.downcase].freeze

    update self.class.card_info_params(infors)
  end

  def promotion
    if DISCOUNT?
      "#{discount}折"
    elsif CASH?
      if least_cost.present? && least_cost > 0
        "满#{least_cost/100}减#{reduce_cost/100}"
      else
        "减#{reduce_cost/100}"
      end
    else
      "其他优惠"
    end
  end

  def quantity
    base_info["sku"]["quantity"]
  end
end
