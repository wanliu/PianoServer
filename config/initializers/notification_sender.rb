=begin

Desc:短信http接口的ruby代码调用示例
author shaoyan
date 2015-10.28

=end

require 'net/http'
require 'uri'

module NotificationSender
  def self.notify(options)
    send_pusher(options)
    send_sms(options)
  end

  def self.send_sms(options)
    params = {}
    mobile_reg = /^1\d{9,10}$/

    order_id = options[:order_id]
    mobile = options[:mobile]
    unless mobile_reg =~ mobile
      puts "短信发送失败，#{mobile}不是一个有效的手机号码！"
      return
    end

    apikey   = Settings.sms.token
    sms_host = Settings.sms.host
    sms_api  = Settings.sms.api_uri
    text     = Settings.promotions.one_money.sms_to_supplier_template
    text     = text.sub("#o_id#", order_id.to_s)

    unless apikey.present? && sms_host.present? && sms_api.present? && text.present?
      return
    end

    #修改为您要发送的手机号码，多个号码用逗号隔开

    #智能匹配模板发送HTTP地址
    send_sms_uri = URI.parse("https://#{sms_host}#{sms_api}")

    params['apikey'] = apikey
    params['mobile'] = mobile
    params['text'] = text

    #智能匹配模板发送
    response = Net::HTTP.post_form(send_sms_uri, params)
    puts response.body + "\n"
  end

  def self.send_pusher(options)
    # {order_id: order.id, order_url: Rails.application.routes.url_helpers.shop_admin_order_path(order.supplier.name, order)}
    MessageSystemService.push_notification(options[:seller_id], options)
  end
end