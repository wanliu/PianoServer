class Api::Promotions::BlessesController < Api::BaseController
  before_action :set_birthday_party, only: [:index, :create]

  # TODO 如果赠送的礼物需要使用微信支付，则传送微信支付所需要的参数到前段
  def create
    @bless = @birthday_party.blesses.build(bless_params)
    @bless.sender = current_user

    if 0 == @bless.virtual_present.price
      @bless.paid = true
    end

    if @bless.save
      render :show, format: :json
    else
      render json: { errors: @bless.errors }, status: :unprocessable_entity
    end
  end

  def show
  end

  private

  def set_birthday_party
    @birthday_party = BirthdayParty.find(params[:birthday_party_id])
  end

  def bless_params
    params.require(:bless).permit(:birthday_party_id, :message, :virtual_present_id)
  end
end