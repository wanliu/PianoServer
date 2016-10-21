class Api::Promotions::CardsController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    @cards = Card.page(params[:page]).per(params[:per])

    render json: {
      cards: @cards,
      page: @cards.current_page,
      total_page: @cards.total_pages 
    }
  end
end