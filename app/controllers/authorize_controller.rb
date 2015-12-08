class AuthorizeController < ApplicationController
  def weixin
    redirect_url = "#{Settings.app.website}/authorize/weixin_redirect_url"
    redirect_to wx_client.authorize_url(redirect_url, Settings.weixin.scope) if wx_client.is_valid?
  end

  def weixin_redirect_url
    code = params[:code]
    # status = false
    tries = 3

    if wx_client.is_valid?
      begin
        access_token = wx_client.get_oauth_access_token(code).result['access_token']
        profile = wx_client.get_oauth_userinfo(wx_client.app_id, access_token).result

        user, status = lookup_user(profile)

        # sign_in(:user, user) 在登陆前，竟然强制保存了 user.
        sign_in(:user, user)
        logger.info "redirect_to: #{to_path(status)}, #{status}"
        return redirect_to(to_path(status), notice: '微信认证登陆成功')
      rescue RestClient::RequestTimeout => e
        tries -= 1
        if tries > 0
          retry
        else
          logger.debug "Weixin Login Timeout!"
          return redirect_to(new_user_session_path, alert: "微信认证服务器超时")
        end
      end
    end

    redirect_to root_path
  end

  private

  def lookup_user(profile)
    logger.info "profile: #{profile.inspect}"

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
    [user, !user.persisted?]
  end

  def to_path(status)
    if status
      after_registers_path
    else
      request.referer ? URI(request.referer).path : root_path
    end
  end
end
