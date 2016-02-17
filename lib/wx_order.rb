module WxOrder
  ORDER_QUERY_URL = "https://api.mch.weixin.qq.com/pay/orderquery"
  WECHAT_CONFIG = Rails.application.config_for(:wechat)

  attr_accessor :wx_order_created, :wx_create_response

  def create_wx_order(options)
    params = prepay_params.merge(options)
    wx_order = WxPay::Service.invoke_unifiedorder params

    self.wx_create_response = wx_order
    self.wx_order_created = wx_order.success?

    if wx_order_created
      prepayid = wx_order["prepay_id"]
      noncestr = wx_order["nonce_str"]

      update_attributes(wx_prepay_id: prepayid, wx_noncestr: noncestr)
    else
      puts "微信支付统一下单失败！", wx_order.to_json
    end

    if wx_create_response_paid? && wx_order_paid?(true)
      self.wx_order_created = true
    end
  end

  def wx_create_response_paid?
    wx_create_response.present? &&
      wx_create_response['return_msg'].present? &&
      "ORDERPAID" == wx_create_response["err_code"]
  end

  def generate_wx_pay_params
    params = {
      appId: appid,
      timeStamp: Time.now.to_i.to_s,
      nonceStr: Devise.friendly_token,
      package: "prepay_id=#{wx_prepay_id}",
      signType: "MD5"
    }

    params[:paySign] = WxPay::Sign.generate(params)

    params
  end

  def verify_wx_notify(result)
    unless result.respond_to?(:[])
      return false
    end

    result["out_trade_no"].to_s == out_trade_no &&
      result["appid"] == appid &&
      result["mch_id"] == mch_id &&
      result["trade_type"] == "JSAPI"# &&
      # result["attach"] == attach
  end

  # 访问微信服务器，查看订单是否完成支付
  # 公众账号ID  appid 是 String(32)  wxd678efh567hg6787  微信分配的公众账号ID（企业号corpid即为此appId）
  # 商户号 mch_id  是 String(32)  1230000109  微信支付分配的商户号
  # 微信订单号 transaction_id  二选一 String(32)  1009660380201506130728806387  微信的订单号，优先使用
  # 商户订单号 out_trade_no  二选一 String(32)  20150806125346  商户系统内部的订单号，当没提供transaction_id时需要传这个。
  # 随机字符串 nonce_str 是 String(32)  C380BEC2BFD727A4B6845133519F3AD6  随机字符串，不长于32位。推荐随机数生成算法
  # 签名  sign  是 String(32)  5K8264ILTKCH16CQ2502SI8ZNMTM67VS  签名，详见签名生成算法
  def wx_order_paid?(udpate_wx_transation_id_if_paid=false)
    params = if wx_transaction_id.present?
      { transaction_id: wx_transaction_id }
    else
      { out_trade_no: out_trade_no }
    end

    res = WxPay::Service.order_query params
    paid = res.present? && verify_wx_notify(res) && "SUCCESS" == res["result_code"]

    if true == paid && true == udpate_wx_transation_id_if_paid
      self.paid = true
      self.wx_transaction_id = res["transaction_id"]
      save(validate: false)
    end

    paid
  end

  private

  def prepay_params
    {
      body: "#{id}号订单支付",
      out_trade_no: out_trade_no,
      total_fee: (total * 100).to_i,
      spbill_create_ip: request_ip,
      notify_url: "#{Settings.app.website}/orders/#{id}/wx_notify",
      trade_type: 'JSAPI'
    }
  end

  def appid
    WECHAT_CONFIG["appid"]
  end

  def mch_id
    WECHAT_CONFIG["mch_id"]
  end

  def secret
    WECHAT_CONFIG["token"]
  end

  def out_trade_no
    if Rails.env.development?
      "development#{id}"
    else
      id.to_s
    end
  end
end