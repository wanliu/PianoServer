wechat_config = Rails.application.config_for(:wechat)

WxPay.appid = wechat_config["appid"]
WxPay.key = wechat_config["token"]
WxPay.mch_id = wechat_config["mch_id"]

WxPay.extra_rest_client_options = {timeout: 1000, open_timeout: 3}