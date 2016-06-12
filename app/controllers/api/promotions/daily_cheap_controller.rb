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
      items_with_gifts = daily_cheap.items_with_gifts
      items = daily_cheap.items
      item_ids = if items_with_gifts.nil? then '' else items_with_gifts.split(',') end
      gift_items = if item_ids.length > 0 then item_ids.map do |id|
        Item.find(id)
      end else
        []
      end

      hash[:items] = items;
      hash[:gift_items] = gift_items.as_json(methods: [:cover_url])

      render json: hash
    else
      render json: {}
    end
  end
end
