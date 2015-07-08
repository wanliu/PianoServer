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

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :mobile, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :current_password) }
  end

  def set_meta_user_data
    if current_user.present?
      set_meta_tags user_id: "w#{current_user.id}", chat_token: current_user.chat_token 
    else
      anonymous_id = "-w#{Time.now.to_i}.#{rand(10000)}"
      anonymous_token = JWT.encode({id: anonymous_id}, User::JWT_TOKEN)
      set_meta_tags user_id: anonymous_id, chat_token: anonymous_token
    end

    set_meta_tags pusher_host: Settings.pusher.socket_host, pusher_port: Settings.pusher.socket_port
  end
end
