class Api::Promotions::OneMoneyController < Api::BaseController
  skip_before_action :authenticate_user!, only: [:show]

  def show
    render json: {}
  end
end
