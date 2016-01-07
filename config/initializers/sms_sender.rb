=begin

Desc:短信http接口的ruby代码调用示例
author shaoyan
date 2015-10.28

=end

require 'net/http'
require 'uri'

module SmsSender
  def self.send_sms(options)
    params = {}
    mobile_reg = /^1\d{9,10}$/

    apikey   = Settings.sms.token
    sms_host = Settings.sms.host
    sms_api  = Settings.sms.api_uri
    text     = Settings.promotions.one_money.sms_to_supplier_template

    unless apikey.present? && sms_host.present? && sms_api.present? && text.present?
      return
    end

    #修改为您要发送的手机号码，多个号码用逗号隔开
    mobile = options[:mobile]
    unless mobile_reg =~ mobile
      puts "短信发送失败，#{mobile}不是一个有效的手机号码！"
      return
    end

    #智能匹配模板发送HTTP地址
    send_sms_uri = URI.parse("https://#{sms_host}#{sms_api}")

    params['apikey'] = apikey
    params['mobile'] = mobile
    params['text'] = text

    #智能匹配模板发送
    response = Net::HTTP.post_form(send_sms_uri, params)
    puts response.body + "\n"
  end
end