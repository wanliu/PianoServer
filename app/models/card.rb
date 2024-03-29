class Card < ActiveRecord::Base
  belongs_to :card_apply_template

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
      Rails.logger.info "[微信卡券]重新拉取微信卡券信息!"
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

    #  AND (least_cost = 0 OR least_cost <= :total)
    #  total: @order.items_total.to_f*100
    def available_with_order(order)
      items_total = order.items_total.to_f*100
      item_ids = order.items.find_all{ |item| item.orderable_type == 'Item'}.map(&:orderable_id)

      tpl_ids = CardTemplateItem.where("item_id IN (?)", item_ids).pluck(:card_apply_template_id)

      availabe_template_ids = CardApplyTemplate.where("id IN (:ids) Or apply_items = :all_items", ids: tpl_ids, all_items: CardApplyTemplate.apply_items["all_items"])
        .pluck(:id)

      availabe_with_items = if availabe_template_ids.present?
        if CardApplyTemplate.default_template.present? && availabe_template_ids.include?(CardApplyTemplate.default_template.id)
          where("card_apply_template_id in (:template_ids) OR card_apply_template_id IS null", template_ids: availabe_template_ids)
        else
          where("card_apply_template_id in (:template_ids)", template_ids: availabe_template_ids)
        end
      else
        none
      end

      availabe_with_items.where("least_cost = 0 OR least_cost <= :total", total: items_total)

      # sql_query = <<-SQL
      #   apply_items = :all_items
      #   OR (
      #     apply_items = :include_items 
      #     AND
      #       card_template_items.item_id IN (:item_ids)
      #   )
      # <<SQL

      # CardApplyTemplate.where("apply_items = :all_items OR ")

      # where("least_cost = 0 OR least_cost <= :total", total: items_total)
      #   .where()
    end

    def exam(wx_card_ids)
      return wx_card_ids if wx_card_ids.blank?

      all_wx_card_ids = pluck(:wx_card_id)
      cash_wx_card_ids = self.CASH.pluck(:wx_card_id)

      if wx_card_ids.any? { |wx_card_id| all_wx_card_ids.exclude? wx_card_id }
        refresh!
        cash_wx_card_ids = self.CASH.pluck(:wx_card_id)
      end

      cash_wx_card_ids & wx_card_ids
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

  def card_apply_template
    super || CardApplyTemplate.default_template
  end

  def card_apply_template_title
    if self[:card_apply_template_id].blank? && card_apply_template.present?
      "#{card_apply_template.title}[默认模板]"
    elsif self[:card_apply_template_id].blank?
      "未设置"
    else
      card_apply_template.title
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
