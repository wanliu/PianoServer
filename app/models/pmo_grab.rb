class PmoGrab < Ohm::Model
  DEFAULT_TIMEOUT = 30.minutes

  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents

  attribute :user_id
  attribute :shop_item_id
  attribute :title
  attribute :price
  attribute :quantity
  attribute :shop_id
  attribute :shop_name
  attribute :time_out, Type::Integer

  # attribute :cover_urls, Type::Array
  attribute :avatar_urls, Type::Array

  attribute :one_money  # 活动的 id , etc OneMoney

  reference :pmo_item, :PmoItem
  # reference :one_money, :OneMoney

  expire :time_out, :expired_time_out
  # expire :end_at, :expired_end_at

  index :user_id
  index :pmo_item_id
  index :one_money

  def before_save
    self.time_out = DEFAULT_TIMEOUT
    if self.pem_item && self.pem_item.is_a?(PmoItem)
      self.pem_item.incr :completes, self.quantity
    end
  end

  def before_delete
    if self.pem_item && self.pem_item.is_a?(PmoItem)
      self.pem_item.decr :completes, self.quantity
    end
  end

  def self.from(pmo_item, one_money, user)
    new({
      user_id: user.user_id,
      shop_item_id: pmo_item.id,
      title: pmo_item.title,
      price: pmo_item.price,
      quantity: pmo_item.quantity,
      shop_id: pmo_item.shop_id,
      shop_name: pmo_item.shop_name,
      avatar_urls: pmo_item.avatar_urls,
      one_money: one_money.id,
      pmo_item: pmo_item
    })
  end

  def callback_url
  end

  private

  def expired_created_at
    self.delete
    # self.status = 'started'
    # save
  end

end
