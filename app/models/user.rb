class User < ActiveRecord::Base
  include AnonymousUser

  enum user_type: [ :consumer, :retail, :distributor, :wholesaler, :manufacturer ]
  # Include default devise modules. Others available are:
  before_save :ensure_authentication_token

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable, :async,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  # has_many :memberings, :dependent => :destroy
  belongs_to :latest_location, class_name: 'Location'
  belongs_to :shop
  belongs_to :industry

  has_one :owner_shop, class_name: 'Shop', foreign_key: 'owner_id'
  has_one :status, as: :stateable, dependent: :destroy
  has_one :cart

  has_many :chats, foreign_key: 'owner_id'
  has_many :locations

  has_many :followers, as: :followable, class_name: 'Follow'
  has_many :followables, as: :follower, class_name: 'Follow'

  has_many :favoritables, as: :favoritor, class_name: 'Favorite'

  has_many :orders, foreign_key: 'buyer_id'

  has_many :evaluations
  has_many :thumbs, foreign_key: :thumber_id, dependent: :destroy

  has_many :shop_delivers, foreign_key: :deliver_id
  has_many :deliverable_shops, through: :shop_delivers, source: :shop

  has_many :blesses, foreign_key: 'sender_id'
  has_many :birthday_parties
  has_many :redpacks, inverse_of: :user

  has_many :sales_men
  has_many :temp_birthday_parties, foreign_key: 'sales_man_id'
  has_many :saled_birthday_parties, class_name: 'BirthdayParty', foreign_key: 'sales_man_id'

  has_many :card_orders

  has_many :consumed_card_codes

  validates :username, presence: true, uniqueness: true
  validates :mobile, presence: true, uniqueness: true

  after_commit :sync_to_pusher

  attr_accessor :login

  delegate :state, to: :status, allow_nil: true

  # admin search configure
  scoped_search on: [:id, :username, :email, :mobile]

  scope :can_import?, -> (id) {
    found = where(id: id).first
    return found.nil? ? true : found.provider == 'import'
  }

  mount_uploader :image, AvatarUploader
  enum sex: {'保密' => 0, '男' => 1, '女' => 2 }
  store_accessor :data,
                 :weixin_openid, :weixin_privilege, :language, :city, :province, :country, :unionid

  JWT_TOKEN = Rails.application.secrets.live_key_base

  def login
    @login || self.username || self.email || self.mobile
  end

  def nickname
    super || login
  end

  def chat_token
    JWT.encode({id: id}, JWT_TOKEN)
  end

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_h).where(["lower(username) = :value OR lower(email) = :value OR lower(mobile) = :value", { :value => login.downcase }]).first
    else
      where(conditions.to_h).first
    end
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def avatar_url
    image.url(:avatar)
  end

  def follows?(target)
    if anonymous?
      false
    else
      followables.exists?(followable_type: target.class, followable_id: target.id)
    end
  end

  def follows!(target)
    unless anonymous?
      followables.create!(followable_type: target.class, followable_id: target.id)
    end
  end

  def unfollows!(target)
    unless anonymous?
      followables.find_by(followable_type: target.class, followable_id: target.id).destroy!
    end
  end

  def anonymous?
    id < 0
  end

  def join_shop
    shop || owner_shop
  end

  def cart
    Cart.find_by(user_id: id) || create_cart
  end

  def sale_mode
    if [:distributor, :wholesaler, :manufacturer].include? user_type
      "wholesale"
    else
      "retail"
    end
  end

  def reach_location_limit?
    locations.count >= Location::AMOUNT_LIMIT
  end

  def is_done?
    case user_type
    when NilClass
      false
    when "retail"
      state == "shop"
    when "distributor"
      state == "product"
    else
      false
    end
  end

  def sales_man?
    sales_men.exists? || owner_shop.present?
  end

  def sms_forward?
    distributor?
  end

  def is_receiver?
    shop_delivers.count > 0
  end

  # TODO deal with Wechat::AccessTokenExpiredError
  def get_wx_card_list(force=false)
    return @wx_card_list_ids if @wx_card_list_ids && !force

    if js_open_id.blank?
      wx_card_list_ids = []
    else
      card_infos = Wechat.api.card_api_ticket.get_card_list js_open_id
      wx_card_list_ids = card_infos.map { |item| item["card_id"] }.uniq
    end

    @wx_card_list_ids = Card.exam(wx_card_list_ids)
  rescue Wechat::AccessTokenExpiredError => e
    Rails.logger.error "[微信卡券] access token过期警告! 微信access_token已经过期"
    @wx_card_list_ids = []
  end

  # 获取用户已领取卡券接口居然把已经核销掉的卡券也返回
  # 因此需要把已经核销掉的卡券排除
  def get_wx_card_codes(wx_card_id)
    return [] if js_open_id.blank?

    card_infos = Wechat.api.card_api_ticket.get_card_list js_open_id, wx_card_id
    consumed_codes = consumed_card_codes.where(wx_card_id: wx_card_id).pluck(:code)

    card_infos.map { |item| item["code"] } - consumed_codes
  rescue Wechat::AccessTokenExpiredError => e
    Rails.logger.error "[微信卡券] access token过期警告! 微信access_token已经过期"
    []
  end

  def has_avaliable_code?(wx_card_id)
    get_wx_card_codes(wx_card_id).present?
  end

  def consume_wx_card(wx_card_id)
    consumed_code = nil

    consumed = get_wx_card_codes(wx_card_id).any? do |code|
      done = consume_wx_card_code code
      Rails.logger.info "[微信卡券]核销卡券#{wx_card_id}:(code:#{code})#{done ? "成功" : "失败"}"
      consumed_code = code if done
      done
    end

    yield consumed_code if block_given? && consumed

    consumed
  end

  def consume_wx_card_code(code)
    Wechat.api.card_api_ticket.consume(code)
  rescue Wechat::AccessTokenExpiredError => e
    Rails.logger.error "[微信卡券] access token过期警告! 微信access_token已经过期"
    false
  end

  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end

  def sync_to_pusher
    return unless persisted?

    pusher_url = Settings.pusher.pusher_url.clone
    pusher_token = Settings.pusher.pusher_token.clone
    pusher_url << 'users'

    options = {id: "#{id}", token: pusher_token, login: username,
      realname: nickname, avatar_url: avatar_url, mobile: mobile, sms_forward: sms_forward? }

    if owner_shop(true).present?
       options.merge! shop_name: owner_shop.title
    end

    begin
      RestClient::Request.execute(method: :post, 
        url: pusher_url,
        payload: options,
        headers: {},
        timeout: 1,
        open_timeout: 1) if pusher_url.present?

      # RestClient.post pusher_url, options
    rescue Errno::ECONNREFUSED, RestClient::RequestTimeout => e
    # rescue Errno::ECONNREFUSED => e
    # TODO what to do when sync fails?
    end
  end

  alias_method :name, :nickname
end
