class VirtualPresent < ActiveRecord::Base

  NAMES = Settings.virtual_presents.names

  validates :title, presence: true
  validates :name, inclusion: { in: NAMES }
  validates :name, uniqueness: true
  validates :price, numericality: { greater__than_or_equal_to: 0 }
  validates :value, numericality: { greater__than_or_equal_to: 0 }

  validate :price_greater_than_value

  private

  def price_greater_than_value
    if price == 0 && value > 1
      errors.add(:base, "免费道具所兑换的现金不能大于１元")
    end

    if price > 0 && price < value
      errors.add(:base, "收费道具的价格不能低于其所兑换的现金")
    end
  end
end
