require 'weixin_api'

class CardOrdersController < ApplicationController
  skip_before_action :authenticate_user!, only: :wx_notify
  skip_before_action :verify_authenticity_token, only: :wx_notify

  def wxpay
    @card_order = current_user.card_orders.find(params[:id])
    if @card_order.paid?
      render "card_orders/wx_paid"
      return
    end

    wx_query_code = params[:code]
    openid = WeixinApi.code_to_openid(wx_query_code)

    @card_order.request_ip = request.ip

    @card_order.create_wx_order(openid: openid)

    if @card_order.wx_order_created
      if @card_order.paid?
        render "card_orders/wx_paid"
      else
        @params = @card_order.generate_wx_pay_params
      end
    else
      flash[:error] = "请求微信支付失败，请稍后再试！错误信息：#{@card_order.wx_create_response['err_code_des']}"
      # redirect_to pay_kind_order_path(@card_order)
      render "card_orders/wx_pay_fail"
    end
  end

  def withdraw
    @card_order = current_user.card_orders.find(params[:id])

    unless @card_order.paid?
      redirect_to WeixinApi.get_openid_url("/card_orders/wxpay/#{card_order.id}")
      return
    end

    if @card_order.withdrew
      if @card_order.pmo_grab_id.present?
        pmo_grab = PmoGrab[@card_order.pmo_grab_id]
        pmo_grab.ensure! if pmo_grab.present?
      end

      render "card_orders/order_withdrew"
      return
    end
  end

  def withdrew
    @card_order = current_user.card_orders.find(params[:id])
    @card_order.withdrew_card

    current_user.user_cards.create(wx_order_id: params[:wx_order_id], encrypt_code: params[:encrypt_code])

    render json: {}
  end

  def wxpay_confirm
    @card_order = current_user.card_orders.find(params[:id])

    if @card_order.paid?
      render json: {paid: true}, status: :ok
    else
      if @card_order.wx_order_paid?
        @card_order.update_attribute('paid', true)

        render json: {paid: true}, status: :ok
      else
        render json: {paid: false}, status: :unprocessable_entity
      end
    end
  end

  def wx_notify
    @card_order = CardOrder.find(params[:id])

    result = Hash.from_xml(request.body.read)["xml"]

    Rails.logger.info "微信支付确认请求，#{result.to_json}"

    if WxPay::Sign.verify?(result) && @card_order.verify_wx_notify(result)
      # find your order and process the post-paid logic.
      @card_order.paid = true
      @card_order.wx_transaction_id = result["transaction_id"]
      @card_order.save(validate: false)

      Rails.logger.info "微信支付成功返回，结果：#{result.to_json}"

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end
end
