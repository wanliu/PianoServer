module OrderWxPay
  def create_wx_order
    params = {
      body: "#{id}号订单支付",
      out_trade_no: id.to_s,
      total_fee: (total * 100).to_i,
      spbill_create_ip: request_ip,
      notify_url: "http://m.wanliu.biz/orders/#{id}/wx_notify",
      trade_type: 'JSAPI',
      opendid: buyer.weixin_openid
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
end