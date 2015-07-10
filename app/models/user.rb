class User < ActiveRecord::Base
  include DefaultImage
  include AnonymousUser
  # Include default devise modules. Others available are:	
  before_save :ensure_authentication_token
  
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  # has_many :memberings, :dependent => :destroy

  image_token -> { self.email || self.username || self.mobile }
  validates :username, presence: true, uniqueness: true

  after_commit :sync_to_pusher

  attr_accessor :login

  JWT_TOKEN = Rails.application.secrets.live_key_base

  def login
    @login || self.username || self.email || self.mobile
  end

  def nickname
    super || login
  end

  def wid
    id > 0 ? "w#{id}" : "-w#{id.abs}"
  end

  def chat_token
    JWT.encode({id: wid}, JWT_TOKEN)
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

    options = {id: "w#{id}", token: pusher_token, login: username, realname: username, avatar_url: (image && image[:avatar_url]) }

    begin
      RestClient.post pusher_url, options
    rescue Errno::ECONNREFUSED => e
      # TODO what to do when sync fails?
    end
  end
end
