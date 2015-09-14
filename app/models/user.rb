class User < ActiveRecord::Base
  include AnonymousUser

  # Include default devise modules. Others available are:
  before_save :ensure_authentication_token

  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :timeoutable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  # has_many :memberings, :dependent => :destroy
  belongs_to :latest_location, class_name: 'Location'

  has_many :chats, foreign_key: 'owner_id'

  has_many :locations

  validates :username, presence: true, uniqueness: true

  after_commit :sync_to_pusher

  attr_accessor :login

  # admin search configure
  scoped_search on: [:id, :username, :email, :mobile]

  scope :can_import?, -> (id) {
    found = where(id: id).first
    return found.nil? ? true : found.provider == 'import'
  }

  mount_uploader :image, ImageUploader
  enum sex: {'男' => 1, '女' => 0 }
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

    options = {id: "#{id}", token: pusher_token, login: username, realname: username, avatar_url: avatar_url }

    begin
      RestClient.post pusher_url, options
    rescue Errno::ECONNREFUSED => e
    # TODO what to do when sync fails?
    end
  end

  alias_method :name, :nickname
end
