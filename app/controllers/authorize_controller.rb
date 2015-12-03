class AuthorizeController < ApplicationController
  def weixin
    redirect_url = "#{Settings.app.website}/authorize/weixin_redirect_url"
    redirect_to wx_client.authorize_url(redirect_url, Settings.weixin.scope) if wx_client.is_valid?
  end

  def weixin_redirect_url
    code = params[:code]

    if wx_client.is_valid?
      access_token = wx_client.get_oauth_access_token(code).result['access_token']
      profile = wx_client.get_oauth_userinfo(wx_client.app_id, access_token).result

      user = User.where('data @> ?', {weixin_openid: profile['openid']}.to_json)
             .first_or_initialize(
               username: SecureRandom.urlsafe_base64.tr('-', '_'),
               weixin_openid: profile['openid'],
               nickname: profile['nickname'],
               sex: profile['sex'],
               language: profile['language'],
               city: profile['city'],
               province: profile['province'],
               country: profile['country'],
               weixin_privilege: profile['privilege']
             )
      user.__send__(:write_attribute, :image, profile['headimgurl'])
      # sign_in(:user, user) 在登陆前，竟然强制保存了 user.
      sign_in(:user, user)
    end
    redirect_to :back
  end
end
