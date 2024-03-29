wechat_config = Rails.application.config_for(:wechat)

WxPay.appid = wechat_config["appid"]
WxPay.key = wechat_config["token"]
WxPay.mch_id = wechat_config["mch_id"]

ssl_p12_path = Rails.application.config_for(:wechat)["ssl_p12_path"]

if !Rails.env.production?
  if ssl_p12_path.present? && File.exist?(ssl_p12_path)
    pass = Rails.application.config_for(:wechat)["ssl_p12_password"]
    WxPay.set_apiclient_by_pkcs12(File.read(ssl_p12_path), pass)
  end
else
  pass = Rails.application.config_for(:wechat)["ssl_p12_password"]
  WxPay.set_apiclient_by_pkcs12(File.read(ssl_p12_path), pass)
end

WxPay.extra_rest_client_options = {timeout: 10, open_timeout: 10}