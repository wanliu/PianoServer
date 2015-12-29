class Admins::OneMoneyController < Admins::BaseController

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
    @one_money = OneMoney[params[:id]]
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

  private

  def one_money_params
    hash = {}
    params[:one_money].each do |k, v|
      hash[k] = v unless v.blank?
    end
    hash
  end
end
