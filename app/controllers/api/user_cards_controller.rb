class Api::UserCardsController < Api::BaseController

  def index
    @cards = current_user.user_cards.order(id: :desc)
      .page(params[:page])
      .per(params[:per])
  end

  # def show
  # end

  def create
    @user_card = current_user.user_cards.build(user_card_params)

    if @user_card.save
      render json: {}
    else
      render json: { errors: @user_card.errors }, status: :unprocessable_entity
    end
  end
  
  # def destroy
  # end

  private

  def user_card_params
    params.require(:user_card).permit(:wx_card_id, :encrypt_code)
  end
end
