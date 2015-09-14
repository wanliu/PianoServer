require 'active_resource'
class ApplicationController < ActionController::Base
  include DebugMode
  include ContentFor

  class_attribute :page_title

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
  before_action :current_subject
  before_action :prepare_system_view_path
  before_action :set_locale

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

    set_meta_tags pusherHost: Settings.pusher.socket_host, pusherPort: Settings.pusher.socket_port
    set_meta_tags user: current_anonymous_or_user.as_json(include_methods: :avatar_url )
    set_meta_tags debug: Settings.debug
  end

  def set_locale
    I18n.locale = params[:locale] || I18n.default_locale
  end

  def module
    nil
  end

  def render_with_page_title(*args)
    prefix = "titles."
    self.page_title +=
      if @title.nil?
        [ t( "titles.controllers.#{controller_name}",
             default: [ :"controllers.#{controller_name}", controller_name ]),
          t( "titles.actions.#{controller_name}.#{action_name}",
             default: [ :"actions.#{action_name}", action_name ]) ]
      else
        [ @title ]
      end

    content_for :title, self.page_title.reverse.join(' ').humanize

    render_without_page_title(*args)
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
    prepend_view_path File.join(Rails.root, Settings.sites.system.root)
  end

  alias_method_chain :render, :page_title
end

ApplicationController.page_title = [ Settings.app.page_title ]
