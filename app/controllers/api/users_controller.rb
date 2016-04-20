class Api::UsersController < Api::BaseController
  # before_action :authenticate_user # only: [:index]
  skip_before_action :authenticate_user!
  skip_before_action :authenticate_user_from_token!
  skip_before_action :verify_signed_out_user_with_token

  def search
    users = User.where("username LIKE ?", "%#{params[:q]}%").limit(10)
    render json: users.to_json(only: [:id], methods: [:avatar_url, :username])
  end
end