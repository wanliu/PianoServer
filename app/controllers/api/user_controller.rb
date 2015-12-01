class Api::UserController < Api::BaseController
  include AnonymousController
  # before_action :authenticate_user # only: [:index]
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  skip_before_action :verify_signed_out_user_with_token

  def index
    @current_user ||= warden.authenticate(scope: :user)
    # logger.info warden.inspect
    render json: current_anonymous_or_user
  end
end
