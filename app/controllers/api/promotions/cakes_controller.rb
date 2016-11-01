class Api::Promotions::CakesController < Api::BaseController
  skip_before_action :authenticate_user!
  before_action :set_cake, only: [:show]

  def index
    @cakes = Cake.order(id: :desc)
      .page(params[:page])
      .per(params[:per])

    render json: {
      cakes: @cakes.as_json(methods: Cake::DELEGATE_ATTRS),
      page: @cakes.current_page,
      total_page: @cakes.total_pages
    }
  end

  def search_items
    search_options = { query: { match: { title: params[:q] } } }

    items = Item.search(search_options).records.limit(10)
    render json: items.as_json(methods: [:title, :cover_url, :shop_name])
  end

  def search_cakes
    search_options = { query: { match: { title: params[:q] } } }
    items = Item.search(search_options).records.limit(20)
    cakes = Cake.where("item_id in (?)", items.map {|item| item.id }).to_a
    json = cakes.map { |cake| cake.item.as_json(methods: [:title, :cover_url, :shop_name]).merge({ cake_id: cake.id }) }

    render json: json
  end

  def show
    @birthday_parties = @cake.birthday_parties.includes(:user)

    @is_sales_man = user_signed_in? && @cake.sales_man?(current_user)
  end

  private

  def set_cake
    @cake = Cake.with_deleted.find(params[:id])
  end
end
