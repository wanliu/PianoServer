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
    items = OneMoney.find(type: 'daily_cheap', is_open: true).sort_by(:start_at, :limit => [start, tail], :order => "DESC ALPHA")
    total_page = (total.to_f / per).ceil

    render json: {
      items: items,
      page: page,
      total_page: total_page
    }
  end

  def latest
    daily_cheaps = OneMoney.find(type: 'daily_cheap', is_open: true).sort_by(:start_at, :limit => [0, 1], :order => "DESC ALPHA")

    if daily_cheaps.length > 0
      daily_cheap = daily_cheaps[0]
      hash = daily_cheap.to_hash
      hash[:items] = daily_cheap.items

      render json: hash
    else
      render json: {}
    end
  end
end
