class Api::Promotions::BlessesController < Api::BaseController

  # TODO 如果赠送的礼物需要使用微信支付，则传送微信支付所需要的参数到前段
  def create
    @bless = current_user.blesses.build(bless_params)

    if 0 == @bless.virtual_present.price
      @bless.paid = true
    end

    if @bless.save
      render json: @bless
    else
      render json: { errors: @bless.errors }
    end
  end

  private

  def bless_params
    params.require(:bless).permit(:birthday_party_id, :message, :virtual_present_id)
  end
end