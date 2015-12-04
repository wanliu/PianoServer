require 'active_resource'
class ApplicationController < ActionController::Base
  include DebugMode
  include ContentFor
  include Piano::PageInfo
  include Errors::RescueError


  # include TokenAuthenticatable
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_meta_user_data
  before_action :current_subject
  before_action :prepare_system_view_path
  before_action :set_locale
  # before_action :mobile_check

  helper_method :current_anonymous_or_user, :anonymous?
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActiveResource::ResourceNotFound, :with => :render_404

  protected

  def current_anonymous_or_user
    current_user || anonymous
  end

  def anonymous
    if session[:anonymous]
      @anonymous = User.anonymous(session[:anonymous])
    else
      @anonymous = User.anonymous
      session[:anonymous] = @anonymous.id
    end
    @anonymous
  end

  def anonymous?
    current_anonymous_or_user.id < 0
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :remember_me) }
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:login, :username, :email, :mobile, :password, :remember_me) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :email, :mobile, :password, :password_confirmation, :current_password) }
  end

  def set_meta_user_data
    if current_user.present?
      set_meta_tags chatId: current_user.id, chatToken: current_user.chat_token
    else
      set_meta_tags chatId: anonymous.id, chatToken: anonymous.chat_token
    end

    set_meta_tags pusherHost: Settings.pusher.socket_host, pusherPort: Settings.pusher.socket_port,
                  user: current_anonymous_or_user.as_json(include_methods: :avatar_url ),
                  debug: Settings.debug,
                  keywords: Settings.app.keywords,
                  description: Settings.app.description
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def module
    nil
  end

  private
  def render_404(exception = nil)
    if exception
        logger.info "Rendering 404: #{exception.message}"
    end

    render :file => "#{Rails.root}/public/404.html", :status => 404, :layout => false
  end

  def current_subject
    @subject ||= Subject.availables.first
  end

  def prepare_system_view_path
    # prepend_view_path File.join(Rails.root, Settings.sites.system.root)
    Liquid::Template.file_system = ContentManagement::FileSystem.new("/", "_%s.html.liquid".freeze)
  end

  def wx_client
    WeixinClient.instance.client
  end

  def mobile_check
    # @is_mobile = is_mobile_request?
  end
end
