require 'weixin_api'

module WxpayController
  def self.included(mod)
    mod.class_eval do
      skip_before_action :authenticate_user!, only: :wx_notify
      skip_before_action :verify_authenticity_token, only: :wx_notify
    end
  end

  def wx_notify
    @order = Order.find(params[:id])

    result = Hash.from_xml(request.body.read)["xml"]

    puts "微信支付确认请求，#{result.to_json}"

    if WxPay::Sign.verify?(result) && @order.verify_wx_notify(result)
      # find your order and process the post-paid logic.
      @order.paid = true
      @order.wx_transaction_id = result["transaction_id"]
      @order.save(validate: false)

      puts "微信支付成功返回，结果：#{result.to_json}"

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def wxpay_test
    # wx_query_code = params[:code]
    # openid = WeixinApi.code_to_openid(wx_query_code)

    # @order = current_user.orders.build id: "-#{rand(1000)}#{rand(1000)}",
    #   total: 0.01

    # @order.request_ip = request.ip

    # @order.create_wx_order(openid: openid)# do |order_created, err_msg|
    #   if order_created
    #     @params = @order.generate_wx_pay_params
    #   else
    #     flash[:error] = "请求微信支付失败，请稍后再试！错误信息：#{err_msg}"
    #     # redirect_to pay_kind_order_path(@order)
    #     render "orders/yiyuan/wx_order_fail"
    #   end
    # end
  end

  def wxpay
    if @order.paid?
      render "orders/yiyuan/wx_paid"
      return
    end

    wx_query_code = params[:code]
    openid = WeixinApi.code_to_openid(wx_query_code)

    @order.request_ip = request.ip

    @order.create_wx_order(openid: openid)

    if @order.wx_order_created
      if @order.paid?
        render "orders/yiyuan/wx_paid"
      else
        @params = @order.generate_wx_pay_params
      end
    else
      flash[:error] = "请求微信支付失败，请稍后再试！错误信息：#{@order.wx_create_response['err_code_des']}"
      # redirect_to pay_kind_order_path(@order)
      render "orders/yiyuan/wx_order_fail"
    end
  end

  def wxpay_confirm
    if @order.paid?
      render json: {paid: true}, status: :ok
    else
      if @order.wx_order_paid?
        @order.update_attribute('paid', true)
        render json: {paid: true}, status: :ok
      else
        render json: {paid: false}, status: :unprocessable_entity
      end
    end
  end

  # def set_wx_pay
  # end
end