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
    item.properties_title(properties)
  end

  private

  def item_and_present_shop
    if item.shop_id != present.shop_id
      errors.add(:present_id, "必须是同一个商店的商品")
    end
  end
end
