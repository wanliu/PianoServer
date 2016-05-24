class Api::Promotions::DailyCheapController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    daily_cheaps = OneMoney.all.select {|o| o.type == 'daily_cheap'}.reverse

    render json: daily_cheaps
  end
end
