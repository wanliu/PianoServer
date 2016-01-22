module WeixinApi
  def self.code_to_openid(code)
    qeury_uri = "https://api.weixin.qq.com/sns/oauth2/access_token?appid=#{appid}&secret=#{secret}&code=#{code}&grant_type=authorization_code"
    
    res = RestClient.get qeury_uri

    message = JSON.parse res.body

    if message["errmsg"].present?
      return nil
    end

    message["openid"]
  end

  def self.appid
    Settings.wx_pay.appid
  end

  def self.secret
    Settings.wx_pay.secret
  end
end