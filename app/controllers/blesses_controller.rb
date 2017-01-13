require 'weixin_api'

class BlessesController < ApplicationController
  skip_before_action :authenticate_user!, only: :wx_notify
  skip_before_action :verify_authenticity_token, only: :wx_notify

  def wxpay
    @bless = Bless.find(params[:id])
    if @bless.paid?
      render "blesses/wx_paid"
      return
    end

    if current_user.js_open_id.blank?
      wx_query_code = params[:code]
      openid = WeixinApi.code_to_openid(wx_query_code)

      current_user.update_column("js_open_id", openid) if openid.present?
    else
      openid = current_user.js_open_id
    end

    @bless.request_ip = request.ip

    @bless.create_wx_order(openid: openid)

    if @bless.wx_order_created
      if @bless.paid?
        render "blesses/wx_paid"
      else
        @params = @bless.generate_wx_pay_params
      end
    else
      flash[:error] = "请求微信支付失败，请稍后再试！错误信息：#{@bless.wx_create_response['err_code_des']}"
      # redirect_to pay_kind_order_path(@bless)
      render "blesses/wx_pay_fail"
    end
  end

  def wxpay_confirm
    @bless = Bless.find(params[:id])

    if @bless.paid?
      render json: {paid: true}, status: :ok
    else
      if @bless.wx_order_paid?
        @bless.update_attribute('paid', true)
        render json: {paid: true}, status: :ok
      else
        render json: {paid: false}, status: :unprocessable_entity
      end
    end
  end

  def wx_notify
    @bless = Bless.find(params[:id])

    result = Hash.from_xml(request.body.read)["xml"]

    Rails.logger.info "微信支付确认请求，#{result.to_json}"

    if WxPay::Sign.verify?(result) && @bless.verify_wx_notify(result)
      # find your order and process the post-paid logic.
      @bless.paid = true
      @bless.wx_transaction_id = result["transaction_id"]
      @bless.save(validate: false)

      Rails.logger.info "微信支付成功返回，结果：#{result.to_json}"

      render :xml => {return_code: "SUCCESS"}.to_xml(root: 'xml', dasherize: false)
    else
      render :xml => {return_code: "FAIL", return_msg: "签名失败"}.to_xml(root: 'xml', dasherize: false)
    end
  end

  def native
    qr_params = Hash.from_xml(request.body.read)["xml"]

    Rails.logger.info "微信扫码支付请求，#{qr_params.to_json}"

    if WxPay::Sign.verify?(qr_params)
      klass, id = qr_params["product_id"].split('_')
      if "bless" == klass
        order = Bless.find_by(id: id)
      elsif "order" == klass
        order = Order.find_by(id: id)
      else
        res = order.wechat_native_err_respnse("参数错误")
        render :xml => res.to_xml(root: 'xml', dasherize: false)
        return
      end

      res = order.wechat_native_respnse

      render :xml => res.to_xml(root: 'xml', dasherize: false)
    else
      res = order.wechat_native_err_respnse("签名失败")
      render :xml => res.to_xml(root: 'xml', dasherize: false)
    end
  end
end
