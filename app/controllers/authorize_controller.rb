class AuthorizeController < ApplicationController
  def weixin
    redirect_url = "#{Settings.app.host}/weixin_redirect_url"
    redirect_to client.authorize_url(redirect_url, 'snsapi_userinfo') if $client.is_valid?
  end

  def weixin_redirect_url
    code = params[:code]

    if client.is_valid?
      access_token = client.get_oauth_access_token(code).result['access_token']
      # profile 返回一个哈希, 格式如下:
      # {
      #   "openid"=>"o0tInv8I0VvpdNyx12tMTy9asT-0",
      #   "nickname"=>"羁绊",
      #   "sex"=>1,
      #   "language"=>"zh_CN",
      #   "city"=>"太原",
      #   "province"=>"山西",
      #   "country"=>"中国",
      #   "headimgurl"=>"http://wx.qlogo.cn/mmopen/Ccnk8Z7hLeMQsChtJJugQ6ronzJsp31TeickDmOBAl2ibRnsgxP3KZpx9LSAGDefATebLVU1Op6wWNyFVXr9H9LBhic1Egws9zE/0",
      #   "privilege"=>[]
      # }
      profile = client.get_oauth_userinfo(client.app_id, access_token).result

      user = User.where('data @> ?', {weixin_openid: profile['openid']}.to_json)

      unless user.exists?
        user = User.create(
               weixin_openid: profile['openid'],
               username: profile['nickname'],
               sex: profile['sex'],
               image: profile['headimgurl'],
               language: profile['language'],
               city: profile['city'],
               province: profile['province'],
               country: profile['country'],
               weixin_privilege: profile['privilege']
             )
      end
      sign_in(:user, user)
    end
    redirect_to :back
  end
end
