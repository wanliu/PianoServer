class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :orderable, polymorphic: true

  # validates :order, presence: true
  validates :orderable, presence: true
  validates :orderable_id, uniqueness: { scope: [:order_id, :orderable_type] }
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates :title, presence: true
  validates :price, numericality: { greater_than: 0 }

  validate :orderable_saleable, on: :create
  validate :gift_saleable, on: :create

  # before_save :set_title, on: :create
  before_save :set_properties

  # 统计/排序 从某个时间起，对商品的卖出数量
  # 只限耒阳地区
  def self.hots_since(time)
    shop_ids = Shop.where(region_id: 430481).pluck(:id)

    select("SUM(order_items.quantity) AS amount, order_items.orderable_id")
      .joins("LEFT JOIN items ON items.id = order_items.orderable_id")
      .where(orderable_type: 'Item')
      .where("items.on_sale = ?", true)
      .where("items.shop_id IN (?)", shop_ids)
      .where("order_items.created_at > ?", time)
      .group("order_items.orderable_id")
      .order("amount desc")
  end

  def orderable
    if orderable_type == 'Promotion'
      Promotion.find(orderable_id)
    else
      super
    end
  end

  def set_initial_attributes
    self.quantity ||= 1
    self.title = orderable.title
    self.price = caculate_price
  end

  # input:
  #   结构：{ gift_id: quantity }
  #   options: {"17"=>"-1.0", "19"=>"2", "22"=>"2"} 
  # output: 
  # [ {gift_id: 19, item_id: 2, quantity: 2, title: 'xxx', avatar_url: 'cvxxx.jpg'},
  #   {gift_id: 22, item_id: 3, quantity: 2, title: 'xxx', avatar_url: 'cvxxx.jpg'} ]
  # gift_id为17的因为quantity小于0，被忽略掉
  def gift_settings(options)
    if orderable.respond_to?(:gifts)
      orderable.gifts.where(id: options.keys).reduce([]) do |settings, gift|
        quantity = options[gift.id.to_s].try(:to_i) || 0
        if quantity > 0
          settings.push({
            gift_id: gift.id,
            item_id: gift.present_id,
            properties: gift.properties,
            quantity: quantity,
            title: gift.composed_title,
            avatar_url: gift.avatar_url
          })
        end

        settings
      end 
    end
  end

  def deduct_stocks!(operator)
    orderable.deduct_stocks!(operator, quantity: quantity, data: properties, source: self)

    gifts.each do |gift_setting|
      item = Item.find(gift_setting["item_id"])
      gift = Gift.find(gift_setting["gift_id"])
      item.deduct_stocks!(operator, quantity: gift_setting["quantity"], data: gift_setting["properties"], kind: :gift, source: self)
      gift.increment!('saled_counter', gift_setting["quantity"].to_i)
    end
  end

  def avatar_url
    if orderable_type == 'Promotion'
      orderable.image_url
    elsif orderable_type == 'Item'
      orderable.avatar_url
    end
  end

  def properties_title(props=properties)
    if orderable.is_a?(Item) && props.present?
      orderable.properties_title(props)
    else
      ""
    end
  end

  def express_fee(delivery_region_id)
    if orderable_type == "Item"
      orderable.express_fee(to: delivery_region_id, quantity: quantity)
    else
      0
    end
  end

  def caculate_price
    case orderable
    when Item
      # if sale_mode == "retail"
        # @order_item.orderable.public_price
      # else
      orderable.price(properties)
      # end
    when Promotion
      orderable.discount_price
    else
      0
    end
  end

  private

  def orderable_saleable
    orderable.saleable?(quantity, properties) do |on_sale, saleable, max|
      if !on_sale
        errors.add(:orderable_id, "已经下架")
      elsif !saleable
        errors.add(:orderable_id, "库存不足")
      end
    end
  end

  # 检查赠品库存是否充足/符合设定，以及防止用户篡改赠品数量
  def gift_saleable
    gifts.each do |gift_setting|
      gift = Gift.find_by(id: gift_setting["gift_id"])
      if gift_setting["quantity"].to_i > gift.eval_available_quantity(quantity)
        errors.add(:gift, "库存不足或者设置变动，请重新提交订单！")
      end
    end
  end

  def set_properties
    if properties.nil?
      self.properties = {}
    end
  end

  # def set_title
  #   self.title = orderable.try(:title)
  # end
end
