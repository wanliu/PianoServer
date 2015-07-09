class ApplicationController < ActionController::Base
  # include TokenAuthenticatable
  layout "mobile"
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  # protect_from_forgery 
  # protect_from_forgery with: :exception
  # skip_before_filter :verify_authenticity_token, only: [ :create ]

  # before_action :configure_permitted_parameters, if: :devise_controller?
  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_meta_user_data

  helper_method :current_user

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :mobile, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :current_password) }
  end

  def anonymous
    User.anonymous
  end

  def current_user
    super.present? ? super : anonymous
  end

  def set_meta_user_data
    if current_user.present?
      set_meta_tags userId: current_user.wid, chatToken: current_user.chat_token 
    # 废弃，current_user 总会返回一个用户
    # else 
    #   anonymous_id = "-w#{Time.now.to_i}.#{rand(10000)}"
    #   anonymous_token = JWT.encode({id: anonymous_id}, User::JWT_TOKEN)
    #   set_meta_tags userId: anonymous_id, chatToken: anonymous_token
    end

    set_meta_tags pusherHost: Settings.pusher.socket_host, pusherPort: Settings.pusher.socket_port
  end
end
