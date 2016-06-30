wechat_config = Rails.application.config_for(:wechat)

WxPay.appid = wechat_config["appid"]
WxPay.key = wechat_config["token"]
WxPay.mch_id = wechat_config["mch_id"]

ssl_p12_path = Rails.application.config_for(:wechat)["ssl_p12_path"]
pass = Rails.application.config_for(:wechat)["ssl_p12_password"]
WxPay.set_apiclient_by_pkcs12(File.read(ssl_p12_path), pass)

WxPay.extra_rest_client_options = {timeout: 1000, open_timeout: 3}