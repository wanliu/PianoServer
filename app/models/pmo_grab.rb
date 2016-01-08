require 'encryptor'

class PmoGrab < Ohm::Model
  # DEFAULT_TIMEOUT = Settings.promotions.one_money.timeout.minutes

  cattr_reader :encryptor
  @@encryptor = Encryptor.new(Rails.application.secrets[:secret_key_base], "one_money")

  include Ohm::Timestamps
  include Ohm::DataTypes
  include Ohm::Callbacks
  include ExpiredEvents

  attribute :user_id
  attribute :shop_item_id
  attribute :title
  attribute :price
  attribute :quantity, Type::Integer
  attribute :shop_id
  attribute :shop_name
  attribute :time_out, Type::Integer
  attribute :callback
  attribute :status

  attribute :avatar_urls, Type::Array
  attribute :timeout_at, OhmTime::ISO8601
  attribute :one_money  # 活动的 id , etc OneMoney

  reference :pmo_item, :PmoItem

  expire :time_out, :expired_time_out
  # expire :end_at, :expired_end_at

  index :user_id
  index :pmo_item_id
  index :one_money

  def before_save
    self.time_out = Settings.promotions.one_money.timeout.minutes.minutes
    self.timeout_at = self.now + self.time_out
    self.status = "pending"
    # pp valid_status_messages
  end

  def after_save
    self.set_expire_time :time_out, self.timeout_at.to_i

  end

  def before_delete
    if self.pmo_item && self.pmo_item.is_a?(PmoItem)
      Rails.logger.debug "Decrement Completes - #{self.quantity}"
      self.pmo_item.decr :completes, self.quantity

      if self.pmo_item.completes < self.pmo_item.total_amount
        if self.pmo_item.status == "suspend"
          if self.now < self.pmo_item.end_at
            self.pmo_item.set_status "started"
            self.pmo_item.save
          end
        end
      end
    end
  end

  def to_hash
    super.merge(attributes)
  end

  def self.from(pmo_item, one_money, user)
    new({
      user_id: user.user_id,
      shop_item_id: pmo_item.item_id,
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
    callback_url!
  rescue => e
    nil
  end

  def callback_url!
    url = real_callback_url
    l = URI.parse(url)
    query = Hash[URI.decode_www_form(l.query || "")]
    encode_message =  encrypt(self.to_hash.to_json)
    query = query.merge("i" => encode_message)
    l.query = URI.encode_www_form(query)
    l.to_s
  end

  def callback_with_fallback
    if pmo_item
      if pmo_item.independence # 独立
        callback_without_fallback
      elsif pmo_item.one_money
        pmo_item.one_money.callback
      else
        nil
      end
    else
      nil
    end
  end

  def ensure!
    self.status = 'created'
    save
    cancel_expire(:timeout)
  rescue
    raise ActiveRecord::RecordInvalid
  end

  alias_method_chain :callback, :fallback

  private
  def real_callback_url
    token_exp = /\{([\w\d\._]*)\}/m
    callback.gsub token_exp do |word|
      token = word[1..-2]
      chains = token.split('.')
      res = chains.inject(self) do |s, m|
        begin
          s.send(m)
        rescue
          ''
        end
      end
    end
  rescue
    nil
  end

  def encrypt(args)
    self.encryptor.encrypt args
  end

  def decrypt(args)
    self.encryptor.decrypt args
  end

  def expired_time_out
    self.delete
    if pmo_item && pmo_item.grabs.find(user_id: user_id).count == 0
      pmo_item.winners.delete(PmoUser.new(id: user_id))
    end
  end
end
