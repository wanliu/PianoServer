require 'encryptor'

class PmoGrab < Ohm::Model
  DEFAULT_TIMEOUT = Settings.promotions.one_money.timeout.minutes

  cattr_reader :encryptor
  @@encryptor = Encryptor.new(Rails.application.secrets[:secret_key_base], "one_money")

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
  attribute :callback

  attribute :avatar_urls, Type::Array

  attribute :one_money  # 活动的 id , etc OneMoney

  reference :pmo_item, :PmoItem

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
    url = real_callback_url
    l = URI.parse(url)
    query = Hash[URI.decode_www_form(l.query)]
    encode_message =  encrypt(self.attributes.to_json)
    query = query.merge("encode_message" => encode_message)
    l.query = URI.encode_www_form(query)
    l.to_s
  rescue => e
    nil
  end


  def callback_with_fallback
    if pmo_item && pmo_item.independence # 独立
      callback_without_fallback
    else
      if pmo_item.one_money
        pmo_item.one_money.callback
      else
        nil
      end
    end
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

  def expired_time_out
    self.delete
  end
end
