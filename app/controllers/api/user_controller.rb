# require 'oj'

class Api::UserController < Api::BaseController
  include AnonymousController
  include FastUsers
  # before_action :authenticate_user # only: [:index]
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  skip_before_action :verify_signed_out_user_with_token

  def index
    # @current_user ||= warden.authenticate(scope: :user)
    # json =
    #   if @current_user
    #     @current_user
    #   elsif session[:anonymous]
    #     anonymous(session[:anonymous])
    #   else
    #     id = (-Time.now.to_i + rand(10000))
    #     session[:anonymous] = id
    #     anonymous(id)
    #   end

    render json: current_user
  end

  # def anonymous(id)
  #   {
  #     id: id,
  #     email: '',
  #     mobile: '',
  #     # created_at: Time.now,
  #     # updated_at: Time.now,
  #     image: {
  #       url: Settings.assets.avatar_image
  #     },
  #     nickname: "游客#{id.abs}",
  #     user_type: "consumer"
  #   }
  # end
end
