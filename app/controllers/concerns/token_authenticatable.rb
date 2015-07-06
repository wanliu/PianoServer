module TokenAuthenticatable
  extend ActiveSupport::Concern

  included do 
	skip_before_action :verify_signed_out_user, only: :destroy, if: :devise_controller?

	before_action :authenticate_user_from_token!
	before_action :verify_signed_out_user_with_token
  end


  # 使用 user.authentication_token 来进行认证
  # 
  # @sample 
  # ```bash 
  # curl -v -H "Accept: application/json" -H "Content-type: application/json" http://127.0.0.1:3000/api/suggestion.json\?auth_token\=\M4kXqwa-Vh_xWdPxoVmQ\&login\=hysios\&suggest\=d
  # ```
  # 这里需要两个 params , `login`, `auth_token`
  # login => User , email, username or mobile
  # auth_token  等于 User authentication_token
  # 实际上这里可以做更复杂的应用，比如检查 Headers access_token 什么的
  # 
  # 参考 https://gist.github.com/danielgatis/5666941
  def authenticate_user_from_token!
    login = auth_params[:login]
    user = login && User.find_for_database_authentication(login: login)
    
    # Notice how we use Devise.secure_compare to compare the token
    # in the database with the token given in the params, mitigating
    # timing attacks.
    if user && Devise.secure_compare(user.authentication_token, auth_params[:auth_token])
      sign_in user, store: false
    end
  end

  def verify_signed_out_user_with_token
  	authenticate_user_from_token!
  	# verify_signed_out_user
  end

  protected

  def verified_request?
    request.content_type == "application/json" || super
  end

  def auth_params
    { 
      login: params[:login].presence || request.headers['X-AUTH-LOGIN'],
      auth_token: params[:auth_token].presence || request.headers['X-AUTH-TOKEN']
    }
  end
end
