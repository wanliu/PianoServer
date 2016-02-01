module OrderWxPay
  ORDER_QUERY_URL = "https://api.mch.weixin.qq.com/pay/orderquery"

  def create_wx_order(options)
    params = {
      body: "#{id}号订单支付",
      out_trade_no: id.to_s,
      total_fee: (total * 100).to_i,
      spbill_create_ip: request_ip,
      notify_url: "#{Settings.app.website}/orders/#{id}/wx_notify",
      trade_type: 'JSAPI',
      openid: options[:openid]
    }

    wx_order = WxPay::Service.invoke_unifiedorder params

    unless wx_order.success?
      puts "微信支付失败！", wx_order["return_msg"]
      yield false, "#{wx_order["return_msg"]}:#{params.to_json}" if block_given?
      return false
    end

    prepayid = wx_order["prepay_id"]
    noncestr = wx_order["nonce_str"]

    if persisted?
      result = update_attributes(wx_prepay_id: prepayid, wx_noncestr: noncestr)
      yield result, nil if block_given?
      result
    else
      self.wx_prepay_id = prepayid
      self.wx_noncestr = noncestr
      yield true, nil if block_given?
      true
    end
  end

  def generate_wx_pay_params
    params = {
      appId: WxPay.appid,
      timeStamp: Time.now.to_i.to_s,
      nonceStr: Devise.friendly_token,
      package: "prepay_id=#{wx_prepay_id}",
      signType: "MD5"
    }

    params[:paySign] = WxPay::Sign.generate(params)

    params
  end

  def verify_wx_notify(result)
    result["out_trade_no"].to_s == id.to_s &&
    result["transaction_id"].to_s == wx_prepay_id &&
    result["appid"] == WxPay.appid &&
    result["mch_id"] == WxPay.mch_id &&
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
  def wx_order_paid?
    params = {
      transaction_id: wx_prepay_id
    }

    res = WxPay.Service.order_query params
    res.present? && verify_wx_notify(res) && "SUCCESS" == res["result_code"]
  end
end