class Api::WeixinConfigsController < Api::BaseController
  skip_before_action :authenticate_user!

  def index
    signature = Wechat.api.jsapi_ticket.signature params[:url] || request.referer

    render json: {
      appId: WxPay.appid, # 必填，公众号的唯一标识
      timestamp: signature[:timestamp], # 必填，生成签名的时间戳
      nonceStr: signature[:noncestr], # 必填，生成签名的随机串
      signature: signature[:signature],# 必填，签名，见附录1
      # jsApiList: ['chooseWXPay', 'onMenuShareTimeline'], # 必填，需要使用的JS接口列表，所有JS接口列表见附录2
      expired_at: Wechat.api.jsapi_ticket.got_ticket_at + Wechat.api.jsapi_ticket.ticket_life_in_seconds
    }
  end
  alias :signature :index

  def card_ext
    options = {}

    options[:openid] = params[:openid] if params[:openid].present?
    options[:code] = params[:code] if params[:code].present?
    options[:card_id] = params[:card_id] if params[:card_id].present?

    result = Wechat.api.card_api_ticket.card_ext(options)

    render json: {card_ext: result}
  end
end