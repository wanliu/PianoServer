class Api::Promotions::DailyCheapController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    params[:page] ||= 1
    params[:per] ||= 6
    page = params[:page].to_i
    per = params[:per].to_i
    start = (page - 1) * per
    tail = page * per

    total = OneMoney.find(type: 'daily_cheap').count
    items = OneMoney.find(type: 'daily_cheap').sort(by: :start_at, :limit => [start, tail], :order => "DESC")
    total_page = (total.to_f / per).ceil

    render json: {
      items: items,
      page: page,
      total_page: total_page
    }
  end
end
