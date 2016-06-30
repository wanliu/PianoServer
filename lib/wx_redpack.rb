module WxRedpack
  WX_REDPACK_REQUEST_URL = %q(https://api.mch.weixin.qq.com/mmpaymkttransfers/sendredpack)
  WX_REDPACK_QUERY_URL = %q(https://api.mch.weixin.qq.com/mmpaymkttransfers/gethbinfo)
  WECHAT_CONFIG = Rails.application.config_for(:wechat)

  class WxPackResponse
    def initialize(response)
      if response.is_a? String
        @response = Hash.from_xml(response_string)["xml"]
      else
        @response = response
      end
    end

    def success
      "SUCCESS" == @response["return_code"] &&
        "SUCCESS" == @response["result_code"]
    end
    alias :success? :success

    def fail
      !success
    end
    alias :fail? :fail

    def error_message
      @response["return_msg"] || @response["err_code_des"]
    end
  end

  class WxPackSendResponse < WxPackResponse; end

  class WxPackQueryResponse < WxPackResponse

    # SENDING:发放中 
    # SENT:已发放待领取 
    # FAILED：发放失败 
    # RECEIVED:已领取 
    # REFUND:已退款
    def status
      if fail?
        "fail"
      else
        @response["status"]
      end
    end

    def fail_reason
      if fail?
        @response["reason"]
      end
    end

    %w(sending sent failed received refound).each do |statu|
      define_method "#{statu}?".to_sym do
        statu.upcase.to_s == status
      end
    end
  end

  def send_redpack
    # ssl_ca_file = Rails.application.config_for(:wechat)["ca_file"]
    # ssl_client_cert = OpenSSL::X509::Certificate.new(File.read(Rails.application.config_for(:wechat)["client_cert"]))
    # ssl_client_key = OpenSSL::PKey::RSA.new(File.read(Rails.application.config_for(:wechat)["client_key"]), "passphrase, if any")
    # ssl_p12_path = Rails.application.config_for(:wechat)["ssl_p12_path"]
    # p12 = OpenSSL::PKCS12.new(File.read(ssl_p12_path), '1268114401')

    # request = RestClient::Resource.new(
    #   # WX_REDPACK_REQUEST_URL,
    #   "https://api.mch.weixin.qq.com",
    #   ssl_client_cert: p12.certificate,
    #   ssl_client_key: p12.key,
    #   ssl_ca_file: "/var/temp/ssl/rootca.pem",
    #   verify_ssl: OpenSSL::SSL::VERIFY_PEER)

    # debugger

    # response = request["mmpaymkttransfers/sendredpack"].post(payload, headers: { content_type: 'application/xml' })

    # response = RestClient::Request.execute({
    #   method: :post,
    #   url: WX_REDPACK_REQUEST_URL,
    #   payload: payload,
    #   ssl_client_cert: p12.certificate,
    #   ssl_client_key: p12.key,
    #   ssl_ca_file: "/var/temp/ssl/rootca.pem",
    #   verify_ssl: OpenSSL::SSL::VERIFY_NONE,
    #   headers: { content_type: 'application/xml' }
    # })
    response = WxPay::Service.sendredpack(redpack_params)
    Rails.logger.info "微信派发红包返回值：#{response.inspect}"
    WxPackSendResponse.new(response)
  end

  def query_redpack
    ssl_client_cert = OpenSSL::X509::Certificate.new(File.read(Rails.application.config_for(:wechat)["client_cert"]))
    ssl_client_key = OpenSSL::PKey::RSA.new(File.read(Rails.application.config_for(:wechat)["client_key"]), "passphrase, if any")
  
    response = RestClient::Request.execute({
      method: :post,
      url: WX_REDPACK_QUERY_URL,
      payload: query_payload,
      ssl_ca_file: Rails.application.config_for(:wechat)["ca_file"],
      # ssl_ca_path: Rails.application.config_for(:wechat)["ca_file"],
      ssl_client_cert: ssl_client_cert,
      ssl_client_key: ssl_client_key,
      verify_ssl: OpenSSL::SSL::VERIFY_PEER,
      headers: { content_type: 'application/xml' }
    })

    WxPackQueryResponse.new(response)
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
      # mch_id: mch_id,
      # wxappid: appid,
      send_name: '耒阳街上',
      # re_openid: user.data["weixin_openid"],
      re_openid: wx_user_openid,
      total_amount: (amount * 100).to_i,
      total_num: 1,
      wishing: '生日趴红包',
      client_ip: '127.0.0.1',
      act_name: '生日趴红包',
      remark: '生日趴红包',
      # nonce_str: Devise.friendly_token
    }

    # sign = WxPay::Sign.generate(params)

    # params.merge(sign: sign)
  end

  # <sign><![CDATA[E1EE61A91C8E90F299DE6AE075D60A2D]]></sign>
  # <mch_billno><![CDATA[0010010404201411170000046545]]></mch_billno>
  # <mch_id><![CDATA[10000097]]></mch_id>
  # <appid><![CDATA[wxe062425f740c30d8]]></appid>
  # <bill_type><![CDATA[MCHT]]></ bill_type> 
  # <nonce_str><![CDATA[50780e0cca98c8c8e814883e5caa672e]]></nonce_str>
  def redpack_querty_params
    {
      mch_billno: mch_billno,
      mch_id: mch_id,
      appid: appid,
      bill_type: 'MCHT',
      nonce_str: Devise.friendly_token
    }
  end

  def payload
    params = redpack_params
    sign = WxPay::Sign.generate(params)
    "<xml>#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{sign}</sign></xml>"
  end

  def query_payload
    params = redpack_params
    sign = WxPay::Sign.generate(params)
    "<xml>#{params.map { |k, v| "<#{k}>#{v}</#{k}>" }.join}<sign>#{sign}</sign></xml>"
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