require 'weixin_api'

module WxpayController
  def self.included(mod)
    mod.class_eval do
      skip_before_action :authenticate_user!, only: :wx_notify
      skip_before_action :verify_authenticity_token, only: :wx_notify
    end
  end

  def waiting_wx_pay
  end

  def wx_notify
    @order = Order.find(params[:id])

    result = Hash.from_xml(request.body.read)["xml"]

    if WxPay::Sign.verify?(result)

      # find your order and process the post-paid logic.
      puts "微信支付成功返回，结果：#{result.to_json}"

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def wxpay_test
    wx_query_code = params[:code]
    openid = WeixinApi.code_to_openid(wx_query_code)

    @order = current_user.orders.build id: "-#{rand(1000)}#{rand(1000)}",
      total: 0.01

    @order.request_ip = request.ip

    @order.create_wx_order(openid: openid) do |order_created, err_msg|
      if order_created
        params = {
          prepayid: @order.wx_prepay_id,
          noncestr: @order.wx_noncestr
        }

        @params = WxPay::Service::generate_app_pay_req params
      else
        flash[:error] = "请求微信支付失败，请稍后再试！错误信息：#{err_msg}"
        # redirect_to pay_kind_order_path(@order)
        render "orders/yiyuan/wx_order_fail"
      end
    end
  end

  def wxpay
  end
end