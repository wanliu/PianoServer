class Admins::OneMoneyController < Admins::BaseController

  before_action :set_one_money, except: [:index, :new, :create, :search, :toggle_open]

  def index
    @one_moneies =
      if params[:type]
        one_money = OneMoney.all.select {|o| o.type == 'daily_cheap'}
        one_money = one_money.reverse
        Kaminari.paginate_array(one_money).page(params[:page])
                .per(10)
      else
        one_money = OneMoney.all.select {|o| o.type == 'one_money'}
        one_money = one_money.reverse
        Kaminari.paginate_array(one_money).page(params[:page])
                .per(10)
      end
  end

  def new
    @one_money = OneMoney.new
  end

  def create
    @one_money = OneMoney.create one_money_params
    redirect_to action: :index
  end

  def signups
    # @one_money = OneMoney
  end

  def details
    @item = PmoItem[params[:item_id].to_i]
  end

  def show
    # @item = PmoItem[params[:item_id]]
    redirect_to edit_admins_one_money_path(@one_money.id)
  end

  def edit
    items_with_gifts = @one_money.items_with_gifts
    item_ids = if items_with_gifts.nil? then '' else items_with_gifts.split(',') end

    @gift_items = if item_ids.length > 0 then item_ids.map do |id|
      Item.find(id)
    end else
      []
    end
  end

  def publish
    # response.headers['Content-Type'] = 'text/event-stream'
    start_at = @one_money.start_at
    name = "%04d-%02d-%02d" % [start_at.year, start_at.month, start_at.day]

    logger.info start_at
    logger.info @one_money.id
    logger.info name

    job_id = OneMoneyPublishWorker.perform_async @one_money.id, name, {type: @one_money.type}
    render json: {
      status: :success,
      job_id: job_id
    }
  end

  def upload_image
    @item = PmoItem[params[:item_id]]
    uploader = NativeUploader.new(@item, :cover_url)
    uploader.store! params[:file]

    cover_urls = @item.cover_urls.unshift(uploader.url(:cover)).uniq
    image_urls = @item.image_urls.unshift(uploader.url).uniq
    @item.cover_urls = cover_urls
    @item.image_urls = image_urls

    @item.save

    render json: { success: true, url: uploader.url(:cover) }
  end

  def upload_one_money_image
    @field = params[:field]

    uploader = NativeUploader.new(@one_money, @field)
    uploader.store! params[:file]

    # @one_money.send(@field, uploader.url)
    # @one_money.save

    render json: { success: true, field: params[:field], url: uploader.url }
  end

  def update
    @one_money.update_attributes one_money_params
    @one_money.save

    redirect_to action: :edit
    # params[]
  end

  def toggle_open
    @one_money.update_attribute('is_open', params[:is_open])

    redirect_to action: :edit
  end

  def search
    q = params[:q]
    if q.to_i == 0
      @items = Item.with_shop_or_product(q)
    else
      item = Item.where(id: q).first
      @items = if item.nil? then [] else [item] end
    end

    render json: {results: @items.map {|item|  { id: item.id,
                                                 text: item.title,
                                                 avatar_url: item.avatar_url,
                                                 shop_name: item.shop.title,
                                                 sid: item.sid,
                                                 price: item.price,
                                                 on_sale: item.on_sale,
                                                 inventory: item.current_stock,
                                                 gifts: item.gifts.as_json(methods: [:title, :avatar_url]) }} }
  end

  def add_item
    item = Item.find(params[:item_id])
    @item = PmoItem.from(item)
    @item.one_money = @one_money
    @item.save
    # @item.set_expire_time(:start_at, @item.start_at)
    # @item.set_expire_time(:end_at, @item.end_at)
  end

  def remove_item
    @item = PmoItem[params[:item_id]]
    if @item.grabs.count == 0
      @item.delete
      @deleted = true
    else
      @deleted = false
    end
  end

  def update_item
    @item = PmoItem[params[:item_id].to_i]
    @item.update_attributes(params[:pmo_item])
    @item.save

    respond_to do |format|
      format.json  { render json: @item }
    end
  end

  def overwrite_item
    @item = PmoItem[params[:item_id].to_i]
    key =  params[:pmo_item].keys.first
    value =  params[:pmo_item].values.first
    @item.set_overwrite_value(key.to_sym, value)
    respond_to do |format|
      format.json  { render json: @item }
    end
  end

  def clear_overwrite_item
    @item = PmoItem[params[:item_id].to_i]
    @item.clear_overwrite(params[:name])
  end

  def clean_expire_grabs
    @item = PmoItem[params[:item_id].to_i]
    @deletes = @item.grabs.select {|grb| grb.expired? }.map { |grb| grb.delete }
  end

  def set_item_completes
    @item = PmoItem[params[:item_id].to_i]
    new_completes = parmas[:pmo_item][:completes].to_i
    diff = new_completes - @item.completes

    @item.incr diff
    @item.save
    format.json  { render json: @item }
  end

  def state_item
    @item = PmoItem[params[:item_id].to_i]
    @item.set_status params[:status] if params[:status]
    @item.save
  end

  def state_item_all
    OneMoney[parmas[:id].to_i].items.each do |pmo_item|
      begin
        @item.set_status params[:status] if params[:status]
        @item.save

      rescue Exception => e
        puts e
      end
    end
  end

  def fix_clock
    @item = PmoItem[params[:item_id].to_i]

    # @item.set_expire_time(:start_at, @item.start_at)
    # @item.set_expire_time(:end_at, @item.end_at)
    @item.save
  end

  # 用户退出统计
  # 在资料页退出的用户　And 在提交订单业退出的用户
  def churn_stastic
    @stastics = {}

    @one_money.items.each do |pmo_item|
      title = pmo_item.title
      stastic = @stastics[title] = {}

      joined_user_ids = PmoGrab.find(pmo_item_id: pmo_item.id)
        .combine(one_money: @one_money.id).map(&:user_user_id)
      stastic[:joined] = joined_user_ids.count

      address_quite_user_ids = User.includes(:locations).where(id: joined_user_ids)
        .select{ |user| user.locations.blank? }.map { |item| item.id.to_s }
      stastic[:address_quite] = address_quite_user_ids.count

      grab_ids = PmoGrab.find(one_money: @one_money.id).combine(pmo_item_id: pmo_item.id).map(&:id)
      ordered_user_ids = Order.where(one_money_id: @one_money.id, pmo_grab_id: grab_ids)
        .pluck(:buyer_id).map(&:to_s)
      stastic[:ordered] = ordered_user_ids.count

      order_quite_user_ids = joined_user_ids - address_quite_user_ids - ordered_user_ids
      stastic[:order_quite] = order_quite_user_ids.count
    end

    @stastics
  end

  def update_items_with_gifts
    @one_money.items_with_gifts = params[:items_with_gifts]
    @one_money.save

    head :no_content
  end

  private

  def one_money_params
    hash = {}
    params[:one_money].each do |k, v|
      hash[k] = v unless v.blank?

      if k == :is_open or k == 'is_open'
        hash[k] = v == 'true'
      end
    end

    hash
  end

  def set_one_money
    @one_money = OneMoney[params[:id].to_i]
  end
end
