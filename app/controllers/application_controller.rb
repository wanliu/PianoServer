require 'active_resource'
class ApplicationController < ActionController::Base
  include DebugMode
  include ContentFor
  include Piano::PageInfo
  include Errors::RescueError
  include Mobylette::RespondToMobileRequests
  include AnonymousController
  # include TokenAuthenticatable
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session

  # before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :set_meta_user_data
  before_action :current_subject
  before_action :current_industry
  before_action :set_current_cart
  before_action :prepare_system_view_path
  before_action :set_locale
  before_action :mobile_filter

  helper_method :current_anonymous_or_user, :anonymous?, :current_cart
  rescue_from ActionController::RoutingError, :with => :render_404
  rescue_from ActiveResource::ResourceNotFound, :with => :render_404
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  mobylette_config do |config|
    # config[:fall_back] = :html
    config[:devices] = { weixin: %r{micromessenger} }
    # config[:skip_xhr_requests] = false
    # config[:mobile_user_agents] = proc { /iphone/i }
  end

  protected

  def current_cart
    @current_cart ||= current_anonymous_or_user.cart
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
                  user: current_anonymous_or_user.as_json(include_methods: :avatar_url, except: [:created_at, :updated_at] ),
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

  def current_industry
    @industry ||= @current_user.try(:industry)
  end

  def set_current_cart
    @current_cart ||= current_anonymous_or_user.cart
  end

  def prepare_system_view_path
    # prepend_view_path File.join(Rails.root, Settings.sites.system.root)
    Liquid::Template.file_system = ContentManagement::FileSystem.new("/", "_%s.html.liquid".freeze)
  end

  def wx_client
    WeixinClient.instance.client
  end

  def authenticate_region!
    @region = cookie_region :region_id do |region, path|
      if region.blank?
        redirect_to path
        return false
      end
    end
  end

  def cookie_region(name, &block)
    @region, path =
      if cookies[name].blank?
        anonymous_or_user_region
      else
        find_region(cookies[name])
      end
    yield @region, path if block_given?
    @region
  end

  def find_region(region_id)
    @region = Region.where(city_id: region_id).first
    if @region.blank?
      [ false, regions_path ]
    else
      [ @region, nil ]
    end
  end

  def anonymous_or_user_region
    if anonymous?
      device_region
    else
      user_region
    end
  end

  def user_region
    case current_user.user_type
    when "consumer"
      [ false, root_path ]
    when "retail", "distributor"
      shop_region(current_user.join_shop)
    else
      [ false, root_path ]
    end
  end

  def shop_region(shop)
    if shop && shop.region
      [ shop.region, nil]
    else
      [ false, regions_path ]
    end
  end

  def device_region
    if request_device?(:weixin) && Settings.dev.feature.weixin
      [ false, authorize_weixin_path ]
    else
      [ false, new_user_session_path ]
    end
  end

  def mobile_filter
    @is_mobile = is_mobile_request?
  end
end
