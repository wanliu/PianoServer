class Cake < ActiveRecord::Base
  paginates_per 15

  belongs_to :item

  validates :item, presence: true
  validates :hearts_limit, numericality: { only_integer: true, greater_than: 0 }
  validates :item_id, uniqueness: { message: "这个商品对应的蛋糕已经存在！" }

  has_many :birthday_parties

  DELEGATE_ATTRS = %i(avatar_url shop_name shop_id title description current_stock cover_url public_price income_price)
  delegate *DELEGATE_ATTRS, to: :item
end
