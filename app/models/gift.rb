class Gift < ActiveRecord::Base
  belongs_to :item
  belongs_to :present, class_name: 'Item'

  enum status: { active: 1, deactive: 2 }

  validates :item, presence: true
  validates :present, presence: true
  validates :present, uniqueness: { scope: [:item_id, :properties] }

  validate :item_and_present_shop

  delegate :title, to: :present, prefix: false
  delegate :avatar_url, to: :present, prefix: false
  delegate :cover_url, to: :present, prefix: false


  def properties_title(props=properties)
    present.properties_title(props)
  end

  def composed_title
    "#{title} #{properties_title}"
  end

  def available_quantity(item_quantity)
    current_stock = present.stocks.find {|stock| stock.data == properties }.try(:quantity) || 0
    quantity_send = (item_quantity * quantity).floor
    result = [left_quantity, current_stock, quantity_send].min

    result > 0 ? result : 0
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
end
