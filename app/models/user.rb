class User < ActiveRecord::Base
  # Include default devise modules. Others available are:	
  before_save :ensure_authentication_token
  
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]

  # has_many :memberings, :dependent => :destroy


  attr_accessor :login

  JWT_TOKEN = ::YAML.load_file("#{::Rails.root}/config/secrets.yml")[::Rails.env]["live_key_base"]

  def login
    @login || self.username || self.email || self.mobile
  end

  def nickname
    super || login
  end

  def live_token
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
 
  private
  
  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end
