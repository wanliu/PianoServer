class PmoItem < Ohm::Model
  DEFAULT_ACTIONS = %(grab)

  include Ohm::Timestamps
  include Ohm::DataTypes
  include ExpiredEvents

  attribute :title
  attribute :description
  attribute :image_urls, Type::Array
  attribute :cover_urls, Type::Array
  attribute :avatar_urls, Type::Array

  attribute :price, Type::Decimal
  attribute :quantity, Type::Integer
  attribute :ori_price, Type::Decimal
  attribute :total_amount, Type::Integer
  attribute :max_executies, Type:Integer

  attribute :shop_category_name
  attribute :category_name
  attribute :status
  attribute :shop_name
  attribute :shop_avatar_url
  attribute :start_at, Type::Time
  attribute :end_at, Type::Time
  attribute :suspend_at, Type::Time

  reference :one_money, :OneMoney

  set :participants, :PmoUser
  set :winners, :PmoUser

  attribute :actions, Type::Array

  # list :logs, :PmoLog

  counter :completes

  index :title
  # index :id

  def self.from(item)

    new({
      title: item.title,
      description: item.description,
      image_urls: item.images.map(&:url),
      cover_urls: item.images.map {|img| img.url(:cover) },
      avatar_urls:  item.images.map {|img| img.url(:avatar) },
      price: item.price || 1,
      ori_price: item.public_price,
      quantity: 1,
      max_executies: 1,
      shop_name: item.shop.title,
      shop_avatar_url: item.shop.avatar_url,
      total_amount: item.current_stock || 10,
      shop_category_name: item.shop_category.try(:title),
      category_name: item.category.try(:title)
    })
  end

  def cover_url
    cover_urls.try :first
  end

  def avatar_url
    avatar_urls.try :first
  end

  def start_at_with_fallback
    start_at_without_fallback || self.one_money.try(:start_at)
  end

  def end_at_with_fallback
    end_at_without_fallback || self.one_money.try(:end_at)
  end

  def suspend_at_with_fallback
    suspend_at_without_fallback || self.one_money.try(:suspend_at)
  end

  def to_hash
    super.merge(attributes)
  end

  def self.find_or_create(item_id)
    item_id = item_id.to_i
    if self[item_id].present?
      return self[item_id]
    else
      item = Item.find(item_id)
      _item = self.from(item)
      _item.save
      _item
    end
  end

  def before_create
    self.actions = DEFAULT_ACTIONS
    self.max_executies = 1
    self.quantity = 1
  end

  alias_method_chain :start_at, :fallback
  alias_method_chain :end_at, :fallback
  alias_method_chain :suspend_at, :fallback

end
