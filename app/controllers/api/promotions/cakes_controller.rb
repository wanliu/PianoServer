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
    @birthday_parties = @cake.birthday_parties.includes(:user)
  end

  private

  def set_cake
    @cake = Cake.with_deleted.find(params[:id])
  end
end