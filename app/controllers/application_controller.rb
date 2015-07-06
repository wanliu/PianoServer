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
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :mobile, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :current_password) }
  end

end
