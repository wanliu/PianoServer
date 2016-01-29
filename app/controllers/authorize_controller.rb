class AuthorizeController < ApplicationController
  include RedirectCallback

  before_action :set_callback, only: [:weixin]

  def weixin
    redirect_url = "#{Settings.app.website}/authorize/weixin_redirect_url"
    authorize_method = mobile? ? :authorize_url : :qrcode_authorize_url
    logger.info wx_client.is_valid?
    logger.info wx_client.inspect
    logger.info wx_client.token_store.inspect
    redirect_to wx_client.send(authorize_method, redirect_url, Settings.weixin.scope) if wx_client.is_valid?
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
        @to_url =  after_sign_in_path(user)
        @notice = '微信认证登陆成功'
      rescue RestClient::RequestTimeout => e
        tries -= 1
        if tries > 0
          retry
        else
          @to_url =  new_user_session_path
          @notice = '微信认证服务器超时'
          logger.debug "Weixin Login Timeout!"
        end
      end
    end

    # redirect_to_with_callback(@to_url, callback_url, notice: @notice)
    redirect_to @to_url, notice: @notice
    # redirect_to root_path
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

  def after_sign_in_path(user)
    if (session[:goto_one_money])
      path = callback_url
      clear_callback

      return path
    end

    return request.referer ? URI(request.referer).path : root_path unless Settings.weixin.after_sign_in

    if user.is_done?
      request.referer ? URI(request.referer).path : root_path
    else
      smart_fills_path
    end
  end
end
