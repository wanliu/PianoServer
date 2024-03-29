class Api::ItemsController < Api::BaseController
  skip_before_action :authenticate_user!

  def search_ly
    @items = Item.search_leiyang_items(params)
      .page(params[:page])
      .per(params[:per])
      .records

    render json: {
      items: @items.as_json(except: [:income_price], methods: [:shop_name, :shop_realname]),
      page: @items.current_page,
      total_page: @items.total_pages
    }
  end

  def search
    @items = if params[:except].present?
      Item.search_all(q: params[:q], except: params[:except]).page(1).per(10).records
    else
      Item.search_all(q: params[:q]).page(1).per(10).records
    end

    render json: @items.as_json(except: [:income_price], methods: [:shop_name, :shop_realname])
  end

  def hots
    config_hots_days = Settings.config.hots_compare_days.try(:to_i) || 30
    start_time = config_hots_days.day.ago

    hots = OrderItem.hots_since(start_time)
      .page(params[:page])
      .per(params[:per] || 20)

    item_ids = hots.map(&:orderable_id)

    @items = Item.where(id: item_ids)

    render json: {
      items: @items.as_json(except: [:income_price], methods: [:shop_name, :shop_realname]),
      page: hots.current_page,
      total_page: hots.total_pages
    }
  end

  def saled_count
    item = Item.find(params[:id])
    since = case params[:since]
      when "month", "m"
        1.month.ago
      when "week", "w"
        1.week.ago
      else
        1.month.ago
      end

    count = item.order_items.where("created_at > :since", since: since).count
    current_stock = item.current_stock

    render json: { saled_count: count, stock: current_stock }
  end

  def gift_item_info
    item = Item.find(params[:id])
    since = case params[:since]
      when "month", "m"
        1.month.ago
      when "week", "w"
        1.week.ago
      else
        1.month.ago
      end

    count = item.order_items.where("created_at > :since", since: since).count
    current_stock = item.current_stock

    gifts = item.gifts.as_json(methods: [:title, :avatar_url, :inventory, :cover_url, :sid, :public_price])

    hash = item.as_json(except: [:income_price, :public_price], methods: [:shop_name, :shop_realname, :shop_address, :shop_avatar])
    hash['avatar_urls'] = [item.avatar_url]
    hash['cover_urls'] = [item.cover_url]
    hash['gifts'] = gifts
    hash['ori_price'] = item.public_price
    hash['saled_count'] = count
    hash['stock'] = current_stock

    render json: hash
  end
end
