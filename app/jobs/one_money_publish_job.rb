class OneMoneyPublishJob < ActiveJob::Base
  queue_as :default

  def perform(one_money, target, options = {sign_url: Settings.app.website + '/authorize/weixin',
                                            api_url: '/api/promotions/one_money',
                                            qr_code: true,
                                            winners_num: 50})
    scripts = Settings.promotions.one_money.scripts.publish

    dir = scripts.dir
    exec = scripts.exec

    context = {
      name: target,
      one_money_id: one_money.id,
      qrcode: options[:qr_code],
      home_img: one_money.cover_url,
      list_img: one_money.head_url,
      api_url: options[:api_url],
      winners: options[:winners_num],
      sign_url: options[:sign_url],
    }

    exec.gsub! /\$(\w+)/ do |m|
      key = $1.to_sym
      context[key]
    end

    Rails.logger.info exec

    `cd #{dir}; #{exec}`
  end
end
