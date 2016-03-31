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

  def deduct_stocks!(operator)
    orderable.deduct_stocks!(operator, quantity: quantity, data: properties, source: self)
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

  def set_properties
    if properties.nil?
      self.properties = {}
    end
  end

  # def set_title
  #   self.title = orderable.try(:title)
  # end
end
