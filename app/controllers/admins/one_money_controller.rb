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

  def show
  end

  def edit
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
                                                 price: item.price,
                                                 inventory: item.current_stock }} }
  end

  def add_item
    @item = PmoItem.find_or_create(params[:item_id])
    @item.one_money = @one_money
    @item.set_expire_time(:start_at, @item.start_at)
    @item.set_expire_time(:end_at, @item.end_at)
    @item.save

  end

  def remove_item
    @item = PmoItem[params[:item_id]]
    @item.delete
  end

  def update_item
    @item = PmoItem[params[:item_id].to_i]
    @item.update_attributes(params[:pmo_item])
    @item.save

    respond_to do |format|
      format.json  { render json: @item }
    end
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
