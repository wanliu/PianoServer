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

  def show
    buyer_ids = OrderItem.joins(:order).where(orderable: @cake.item).pluck("orders.buyer_id").uniq
    @buyers = User.where(id: buyer_ids)
  end

  private

  def set_cake
    @cake = Cake.find(params[:id])
  end
end