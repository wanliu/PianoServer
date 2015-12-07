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

  has_many :orders, foreign_key: 'buyer_id'

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
                 :weixin_openid, :weixin_privilege, :language, :city, :province, :country

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

    options = {id: "#{id}", token: pusher_token, login: username, realname: nickname, avatar_url: avatar_url }

    begin
      RestClient.post pusher_url, options
    rescue Errno::ECONNREFUSED => e
    # TODO what to do when sync fails?
    end
  end

  alias_method :name, :nickname
end
