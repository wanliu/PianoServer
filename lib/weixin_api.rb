module WeixinApi
  class << self
    def code_to_openid(code)
      qeury_uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{secret}&code=#{code}&grant_type=authorization_code"
      
      res = RestClient.get qeury_uri

      message = JSON.parse res.body

      if message["errmsg"].present?
        return nil
      end

      message["openid"]
    end

    def appid
      wechat_config = Rails.application.config_for(:wechat)
      wechat_config["appid"]
    end

    def secret
      wechat_config = Rails.application.config_for(:wechat)
      wechat_config["secret"]
    end

    def get_openid_url(redirect_target)
      host = Settings.app.website
      redirect_uri = ERB::Util.url_encode("#{host}#{redirect_target}")
      "https://open.weixin.qq.com/connect/oauth2/authorize?appid=#{appid}&redirect_uri=#{redirect_uri}&response_type=code&scope=snsapi_base&state=STATE#wechat_redirect"
    end
  end
end