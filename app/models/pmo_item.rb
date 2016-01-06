require 'redlock'

class PmoItem < Ohm::Model
  LOCK_TIMEOUT = Settings.promotions.lock_timeout

  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
  include ExpiredEvents

  cattr_reader :dlm

  attribute :title
  attribute :description
  attribute :image_urls, Type::Array
  attribute :cover_urls, Type::Array
  attribute :avatar_urls, Type::Array
  attribute :item_id, Type::Integer

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
  attribute :start_at, OhmTime::ISO8601
  attribute :end_at, OhmTime::ISO8601
  attribute :suspend_at, OhmTime::ISO8601

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
      item_id: item.id,
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

  # def suspend_at_with_fallback
  #   if self.independence
  #     suspend_at_without_fallback
  #   else
  #     self.one_money.try(:suspend_at)
  #   end
  # end

  def status_with_timing
    if status_without_timing.blank? or
       status_without_timing  == "invalid" or
       status_without_timing == "timing"

      if start_at && end_at
        if self.now >= start_at
          "started"
        else
          if self.now >= end_at
            "end"
          else
            "timing"
          end
        end
      else
        "invalid"
      end
    else
      status_without_timing
    end
  end

  def set_status(state)
    self.suspend_at = self.now if state.to_s == "suspend"
    self.status = state
  end

  def to_hash
    super.merge(attributes.except(:start_at, :end_at).merge({
      start_at:　self.start_at,
      end_at: self.end_at
    })
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
    self.max_executies = 1
    self.quantity = 1
    self.status = "timing"
  end

  def valid_status?
    valid_status_messages.present? && valid_status_messages.values.all? {|v| v == true}
  end

  def valid_status_messages
    msgs = {}
    time = self.now
    if time < self.start_at
      if expire_running?(:start_at)
        msgs["start_at"] = true
      else
        msgs["start_at"] = "计时器未开启"
      end
    elsif self.start_at <= time and time <= self.end_at
      if self.status == "started"
        msgs["start_at"] = true
      else
        msgs["start_at"] = "未启动"
      end

      if expire_running?(:end_at)
        msgs["end_at"] = true
      else
        msgs["end_at"] = "计时器未开启"
      end
    # elsif time > self.end_at
    else
      if self.status == "end"
        msgs["end_at"] = true
      else
        msgs["end_at"] = "未启动"
      end
    end
    msgs
  end

  def lock_incr(attribute, quantity)
    key_name = "#{key}:__lock.#{attribute}"
    _incr = 0
    3.times {
      inc_lock = self.dlm.lock(key_name, LOCK_TIMEOUT)
      if inc_lock
        if inc_lock[:validity] > 50
            # Note: we assume we can do it in 500 milliseconds. If this
            # assumption is not correct, the program output will not be
            # correct.
            self.incr attribute, quantity
            _incr += 1
        end
        dlm.unlock(inc_lock)
      end
    }
    _incr
  end

  def lock_decr(attribute, quantity)
    key_name = "#{key}:__lock.#{attribute}"
    _incr = 0
    3.times {
      inc_lock = self.dlm.lock(key_name, LOCK_TIMEOUT)
      if inc_lock
        if inc_lock[:validity] > 50
            # Note: we assume we can do it in 500 milliseconds. If this
            # assumption is not correct, the program output will not be
            # correct.
            self.decr attribute, quantity
            _incr += 1
        end
        dlm.unlock(inc_lock)
      end
    }
    _incr
  end

  alias_method_chain :start_at, :fallback
  alias_method_chain :end_at, :fallback
  protected

  def self.redis_url
    redis_config = Rails.application.config.redis_config
    host = redis_config["host"]
    port = redis_config["port"]
    db = redis_config["db"] || '0'
    auth = redis_config['auth'] ? ":#{redis_config['auth']}@" : ''
    url = "redis://#{auth}#{host}:#{port}/#{db}"
  end

  @@dlm = Redlock.new(self.redis_url)

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
