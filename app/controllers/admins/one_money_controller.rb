class Admins::OneMoneyController < Admins::BaseController
  before_action :set_one_money, except: [:index, :new, :create, :search]

  def index
    @one_moneies = OneMoney.all
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

  def update
    @one_money.update_attributes one_money_params
    @one_money.save

    redirect_to action: :edit
    # params[]
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
                                                 inventory: item.current_stock }} }
  end

  def add_item
    item = Item.find(params[:item_id])
    @item = PmoItem.from(item)
    @item.one_money = @one_money
    @item.set_expire_time(:start_at, @item.start_at)
    @item.set_expire_time(:end_at, @item.end_at)
    @item.save

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

  def fix_clock
    @item = PmoItem[params[:item_id].to_i]

    @item.set_expire_time(:start_at, @item.start_at)
    @item.set_expire_time(:end_at, @item.end_at)
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

  private

  def one_money_params
    hash = {}
    params[:one_money].each do |k, v|
      hash[k] = v unless v.blank?
    end
    hash
  end

  def set_one_money
    @one_money = OneMoney[params[:id].to_i]
  end
end
