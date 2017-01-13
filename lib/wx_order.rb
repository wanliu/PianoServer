module WxOrder
  ORDER_QUERY_URL = "https://api.mch.weixin.qq.com/pay/orderquery"
  WECHAT_CONFIG = Rails.application.config_for(:wechat)

  attr_accessor :wx_order_created, :wx_create_response, :request_ip

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
      Rails.logger.info "[微信]微信支付统一下单失败！, options:#{params.inspect}, responses: #{wx_order.inspect}"
      # puts "微信支付统一下单失败！", 'options:', params.to_json, ',responses:', wx_order.to_json
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
      self.paid_total = wx_total_fee if is_a? Order
      save(validate: false)
    end

    paid
  end

  def wx_total_fee
    wx_pay_discount = if Settings.promotions.one_money.wx_pay_discount.present?
      Settings.promotions.one_money.wx_pay_discount
    else
      0
    end

    total_fee = total - wx_pay_discount

    total_fee > 0 ? total_fee : 0
  end

  # 微信扫码支付模式一,详情:
  # https://pay.weixin.qq.com/wiki/doc/api/native.php?chapter=6_4
  # 支付二维码规则:
  # //wxpay/bizpayurl?sign=XXXXX&appid=XXXXX&mch_id=XXXXX&product_id=XXXXXX&time_stamp=XXXXXX&nonce_str=XXXXX
  def wechat_native_qrcode_path
    if self.wechat_native_qrcode.blank?
      content = wechat_native_content

      qrcode = RQRCode::QRCode.new(content)

      # With default options specified explicitly
      png = qrcode.as_png(
                resize_gte_to: false,
                resize_exactly_to: false,
                fill: 'white',
                color: 'black',
                size: 320,
                border_modules: 4,
                module_px_size: 6,
                file: nil # path to write
                )

      File.open("/tmp/orderqr_#{self.class.to_s.downcase}_#{id}.temp.png", 'wb') do |file|
        file.write png.to_s

        self.wechat_native_qrcode = file
      end

      save
    end 

    wechat_native_qrcode.url
  end

  def wechat_native_content
    time_stamp = Time.now.to_i
    nonce_str = Devise.friendly_token
    appid = "wx3fe5b90f6015df42"
    mch_id = "1303592101"
    order_id = out_trade_no

    params = {
      appid: appid,
      mch_id: mch_id,
      product_id: order_id,
      time_stamp: time_stamp,
      nonce_str: nonce_str
    }
    sign = WxPay::Sign.generate(params)

    "weixin://wxpay/bizpayurl?sign=#{sign}&appid=#{appid}&mch_id=#{mch_id}&product_id=#{order_id}&time_stamp=#{time_stamp}&nonce_str=#{nonce_str}"
  end

  def wechat_native_respnse
    options = {
      return_code: "SUCCESS",
      return_msg: '',
      appid: appid,
      mch_id: mch_id,
      nonstr: Devise.friendly_token,
      prepay_id: prepay_id,
      result_code: "SUCCESS"
    }

    sign = WxPay::Sign.generate(params)

    options.merge(sign: sign)
  end

  def wechat_native_err_response(err_msg)
    options = {
      return_code: "FAIL",
      return_msg: err_msg,
      appid: appid,
      mch_id: mch_id,
      nonstr: Devise.friendly_token,
      prepay_id: prepay_id,
      result_code: "FAIL"
    }

    sign = WxPay::Sign.generate(params)

    options.merge(sign: sign)
  end

  private

  def prepay_params
    # 微信支付优惠
    {
      body: "#{id}号订单支付",
      out_trade_no: out_trade_no,
      total_fee: (wx_total_fee * 100).to_i,
      spbill_create_ip: request_ip,
      notify_url: wx_order_notify_url,
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

  # 使用Settings.wxpay.wx_order_prefix来区分测试版本和线上版本，避免订单号冲突
  def out_trade_no
    no = if Settings.wxpay && Settings.wxpay.wx_order_prefix
      "#{self.class.to_s.downcase}_#{Settings.wxpay.wx_order_prefix}_#{id}"
    else
      "#{self.class.to_s.downcase}_#{id}"
    end

    if Rails.env.development?
      "development_#{no}"
    else
      no
    end
  end
end