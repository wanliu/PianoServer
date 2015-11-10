class Admin < ActiveRecord::Base
  include PublicActivity::Model
  tracked

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  options = [ :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :authentication_keys => [:login]]

  options.delete :registerable unless Settings.admin.register.open
  devise *options

  has_many :activities, as: :recipient

  attr_accessor :login

  scope :system_admin, -> () do
    Admin.new(id: 0)
  end


  def self.find_for_database_authentication(warden_conditions)
	  conditions = warden_conditions.dup
	  if login = conditions.delete(:login)
	    where(conditions.to_h).where(["lower(email) = :value", { :value => login.downcase }]).first
	  else
	    where(conditions.to_h).first
	  end
	end
end
