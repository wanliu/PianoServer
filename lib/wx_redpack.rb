module WxRedpack
  WX_REDPACK_REQUEST_URL = %q(https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack)
  WECHAT_CONFIG = Rails.application.config_for(:wechat)

  class WxPackSendResponse
    def initialize(response_string)
      @response = JSON.parse(response_string)
    end

    def success
      "SUCCESS" == @response["result_code"]
    end
    alias :success?, :success

    def fail
      !success
    end
    alias :fail? :fail
  end

  def send_redpack
    response = RestClient::Request.execute({
      method: :post,
      url: WX_REDPACK_REQUEST_URL,
      payload: payload,
      headers: { content_type: 'application/xml' }
    })

    WxPackSendResponse.new(response)
  end

  def check_redpack
  end

  def check_pay_status
  end

  private
  # <mch_billno><![CDATA[0010010404201411170000046545]]></mch_billno>
  # <mch_id><![CDATA[888]]></mch_id>
  # <wxappid><![CDATA[wxcbda96de0b165486]]></wxappid>
  # <send_name><![CDATA[send_name]]></send_name>
  # <re_openid><![CDATA[onqOjjmM1tad-3ROpncN-yUfa6uI]]></re_openid>
  # <total_amount><![CDATA[200]]></total_amount>
  # <total_num><![CDATA[1]]></total_num>
  # <wishing><![CDATA[恭喜发财]]></wishing>
  # <client_ip><![CDATA[127.0.0.1]]></client_ip>
  # <act_name><![CDATA[新年红包]]></act_name>
  # <remark><![CDATA[新年红包]]></remark>
  # <nonce_str><![CDATA[50780e0cca98c8c8e814883e5caa672e]]></nonce_str>

  def redpack_params
    {
      mch_billno: mch_billno,
      mch_id: mch_id,
      wxappid: appid,
      send_name: '耒阳街上',
      # re_openid: user.data["weixin_openid"],
      re_openid: wx_user_openid,
      total_amount: (amount * 100).to_i,
      total_num: 1,
      wishing: '生日趴红包',
      client_ip: '127.0.0.1',
      act_name: '生日趴红包',
      remark: '生日趴红包',
      nonce_str: Devise.friendly_token
    }

    # sign = WxPay::Sign.generate(params)

    # params.merge(sign: sign)
  end

  def payload
    sign = WxPay::Sign.generate(redpack_params)
    "<xml>#{redpack_params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{sign}</sign></xml>"
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

  def mch_billno
    "#{mch_id}#{created_at.strftime("%y%m%d")}#{wx_order_no}"
  end
end