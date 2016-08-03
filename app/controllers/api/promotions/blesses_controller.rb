class Api::Promotions::BlessesController < Api::BaseController
  before_action :set_birthday_party, only: [:index, :create]
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @total = @birthday_party.blesses.paid.count

    @blesses = @birthday_party.blesses
      .includes(:sender, :virtual_present)
      .order(id: :desc)
      .paid
      .limit(params[:limit].to_i + 1)
      .offset(0)

    @blesses = @blesses.where('id < ?', params[:latest_id].to_i) if params[:latest_id].present?

    @total = @total
  end

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
      render json: { errors: @bless.errors.full_messages.join(', ')}, status: :unprocessable_entity
    end
  end

  def show
    @bless = Bless.find(params[:id])
  end

  def wx_pay_params
    params = @bless.generate_wx_pay_params

    render json: {
      timestamp: params[:timeStamp], # 支付签名时间戳，注意微信jssdk中的所有使用timestamp字段均为小写。但最新版的支付后台生成签名使用的timeStamp字段名需大写其中的S字符
      nonceStr:  params[:nonceStr], # 支付签名随机串，不长于 32 位
      package:   params[:package], # 统一支付接口返回的prepay_id参数值，提交格式如：prepay_id=***）
      signType:  params[:signType], # 签名方式，默认为'SHA1'，使用新版支付需传入'MD5'
      paySign:   params[:paySign]
    }
  end

  private

  def set_birthday_party
    @birthday_party = BirthdayParty.find(params[:birthday_party_id])
  end

  def bless_params
    params.require(:bless).permit(:birthday_party_id, :message, :virtual_present_id)
  end
end
