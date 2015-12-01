class Api::UserController < Api::BaseController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    logger.info session.keys
    render nothing: true
  end
end
