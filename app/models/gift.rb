class Gift < ActiveRecord::Base
  belongs_to :item
  belongs_to :present, class_name: 'Item'

  attr_accessor :available_quantity

  enum status: { active: 1, deactive: 2 }

  validates :item, presence: true
  validates :present, presence: true
  validates :present, uniqueness: { scope: [:item_id, :properties] }

  validate :item_and_present_shop

  validate :saled_counter_with_total

  delegate :title, to: :present, prefix: false
  delegate :avatar_url, to: :present, prefix: false
  delegate :cover_url, to: :present, prefix: false
  delegate :current_stock, to: :present, prefix: false
  delegate :sid, to: :present, prefix: false


  def properties_title(props=properties)
    present.properties_title(props)
  end

  def composed_title
    "#{title} #{properties_title}"
  end

  def eval_available_quantity(item_quantity)
    current_stock = present.stocks.find {|stock| stock.data == properties }.try(:quantity) || 0
    quantity_send = (item_quantity * quantity).floor
    self.available_quantity = [left_quantity, current_stock, quantity_send].min.to_i
  end

  def left_quantity
    total - saled_counter
  end

  private

  def item_and_present_shop
    if item.shop_id != present.shop_id
      errors.add(:present_id, "必须是同一个商店的商品")
    end
  end

  def saled_counter_with_total
    if saled_counter > total
      errors.add(:saled_counter, '赠品可赠送量不足或者赠品变更，请重新提交订单')
    end
  end
end
