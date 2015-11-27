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

  def orderable
    if orderable_type == 'Promotion'
      Promotion.find(orderable_id)
    else
      super
    end
  end

  def deduct_stocks!(operator)
    orderable.deduct_stocks!(operator, quantity: quantity, data: properties)
  end

  def avatar_url
    if orderable_type == 'Promotion'
      orderable.image_url
    elsif orderable_type == 'Item'
      orderable.avatar_url
    end
  end

  private

  def orderable_saleable
    unless orderable.saleable?(quantity, properties)
      errors.add(:orderable_id, "库存不足，或者已经下架")
    end
  end

  # def set_title
  #   self.title = orderable.try(:title)
  # end
end
