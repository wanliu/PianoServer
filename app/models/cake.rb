class Cake < ActiveRecord::Base
  paginates_per 15

  belongs_to :item

  validates :item, presence: true
  validates :hearts_limit, numericality: { only_integer: true, greater_than: 0 }
  validates :item_id, uniqueness: { message: "这个商品对应的蛋糕已经存在！" }

  delegate :avatar_url, :shop_name, :title, to: :item
end
