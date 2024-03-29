class Users::SessionsController < Devise::SessionsController
  include TokenAuthenticatable
  include ApplicationHelper
  include RedirectCallback

  before_action :set_callback, only: :new
  after_action :clear_callback, only: :create
  after_action :after_login, :only => :create

  layout "sign"

  after_action :combine_anonymous_cart_items, only: [:create]
  # skip_before_action :verify_signed_out_user, only: :destroy

  respond_to :json, :html

  TYPES = %w(mobile email name)
  helper ApplicationHelper

  include Mobylette::RespondToMobileRequests
  # skip_before_filter :verify_authenticity_token
  # before_filter :configure_sign_in_params, only: [:create]

  def _render_with_renderer_json (resource, options ={})
    options.merge! formats: [:json]
    template = File.read(Rails.root.join('app/views/api/users/_user.json.jbuilder'));
    resource_json = Jbuilder.new do |json|
      @json_options = { user: :simple }
      @enabled_token = true
      user = resource
      instance_eval template, __FILE__, __LINE__
    end
    # logger.info resource_json.target!
    super({user: JSON.parse(resource_json.target!)}, options)
  end

  def new
    @login_type = 'login'
    super
  end

  def create
    params[:format] = "html"
    if auth_hash
      logger.info auth_hash
    end

    super
    # render :show, formats: [:json]
  end

  # 注意: 这里并没有实现 authentication_token 的 api logout
  # 因为在 session signout 没法确定 current_user , authenticate_user! 是
  # 基于 cookies 的来识别身份的。所以我们暂不支持 json 方式的登出
  #
  # ** 已改动
  # 通过新增 verify_signed_out_user_with_token filter in TokenAuthenticatable
  # 我们已经解决了登陆的问题
  def destroy
    current_user && current_user.authentication_token = nil
    # current_user.save
    super
  end

  def after_login
    if @current_user.join_shop && @current_user.join_shop.region
      cookies.delete :region_id
    end
  end

  private

  def login_type
    TYPES.include?(params[:login_type]) ? params[:login_type] : default_type
  end

  def default_type
    mobile? ? 'mobile' : 'email'
  end

  def after_sign_in_path_for(resource)
    unless Settings.after_registers.after_sign_in
      return session[:callback] || stored_location_for(:user) || root_path || super(resource)
    end

    if resource.is_done?
      session[:callback] || stored_location_for(:user) || root_path || super(resource)
    else
      Settings.after_registers.after_sign_in_path || after_registers_path
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  private

  def combine_anonymous_cart_items
    return unless session[:anonymous].present?

    anonymous_id = session[:anonymous]
    anonymous_cart = Cart.find_by(user_id: anonymous_id)

    if anonymous_cart.present?
      resource.cart.combine anonymous_cart
      anonymous_cart.items(true)
      anonymous_cart.destroy
    end
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end
end
