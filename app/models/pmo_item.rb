class PmoItem < Ohm::Model
  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
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
  attribute :max_executies, Type::Integer

  attribute :shop_category_name
  attribute :category_name
  attribute :status
  attribute :shop_name
  attribute :shop_id
  attribute :shop_avatar_url
  attribute :start_at, Type::Time
  attribute :end_at, Type::Time
  attribute :suspend_at, Type::Time

  attribute :independence, Type::Boolean

  set :participants, :PmoUser
  set :winners, :PmoUser

  collection :grabs, :PmoGrab
  reference :one_money, :OneMoney

  # list :logs, :PmoLog
  expire :start_at, :expired_start_at
  expire :end_at, :expired_end_at

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
      shop_id: item.shop.id,
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
    if self.independence
      start_at_without_fallback
    else
      self.one_money.try(:start_at)
    end
  end

  def end_at_with_fallback
    if self.independence
      end_at_without_fallback
    else
      self.one_money.try(:end_at)
    end
  end

  def suspend_at_with_fallback
    if self.independence
      suspend_at_without_fallback
    else
      self.one_money.try(:suspend_at)
    end
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
      pp _item
      _item.save
      _item
    end
  end

  def before_create
    self.max_executies = 1
    self.quantity = 1
  end

  def valid_status?
    (self.start_at < Time.now && self.status == "started") ||
    (self.end_at < Time.now && self.status == "end") ||
    (self.start_at > Time.now && expire_running?(:start_at)) ||
    (self.end_at > Time.now && expire_running?(:end_at))
  end

  def valid_status_messages
    msgs = {}
    if self.start_at < Time.now # 开始后
      if self.status == "started"
        msgs["start_at"] = true
      else
        msgs["start_at"] = "未启动"
      end
    else                        # 未开始前
      if expire_running?(:start_at)
        msgs["start_at"] = true
      else
        msgs["start_at"] = "计时器未开启"
      end
    end

    if self.end_at < Time.now # 已结束
      if self.status == "end"
        msgs["end_at"] = true
      else
        msgs["end_at"] = "未启动"
      end
    else                      # 未结束
      if expire_running?(:end_at)
        msgs["end_at"] = true
      else
        msgs["end_at"] = "计时器未开启"
      end
    end
    msgs
  end

  alias_method_chain :start_at, :fallback
  alias_method_chain :end_at, :fallback
  alias_method_chain :suspend_at, :fallback

  private

  def expired_start_at
    self.status = 'started'
    save
  end

  def expired_end_at
    self.status = 'end'
    save
  end
end
