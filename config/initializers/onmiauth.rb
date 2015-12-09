Rails.application.config.middleware.use OmniAuth::Builder do
  provider :wechat, Settings.weixin.app_id, Settings.weixin.secret,  :authorize_params => { :scope => Settings.weixin.scope }
end
