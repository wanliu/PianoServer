class Cake < ActiveRecord::Base
  acts_as_paranoid
  
  paginates_per 15

  SUPPLIERS = Settings.cakes.try(:suppliers) || []

  belongs_to :item

  validates :item, presence: true
  validates :hearts_limit, numericality: { only_integer: true, greater_than: 0 }
  validates :item_id, uniqueness: { message: "这个商品对应的蛋糕已经存在！" }
  validates :supplier, inclusion: { in: SUPPLIERS }

  has_many :birthday_parties

  DELEGATE_ATTRS = %i(avatar_url images shop_name shop_id title description current_stock cover_url public_price income_price properties stocks_with_index properties_setting)
  delegate *DELEGATE_ATTRS, to: :item

  def shop
    item.shop
  end

  def sales_man?(user)
    user_id = if user.is_a? User
      user.id
    else
      user
    end

    shop.sales_men.exists?(user_id: user_id) || shop.owner_id == user_id
  end
end
