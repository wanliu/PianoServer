require 'sidekiq'
require 'sidekiq-status'

class OneMoneyPublishWorker
  include Sidekiq::Worker
  include Sidekiq::Status::Worker

  def perform(one_money_id, target, options = {sign_url: Settings.app.website + '/authorize/weixin',
                                            api_url: '/api/promotions/one_money',
                                            qr_code: true,
                                            prefix: Settings.promotions.one_money.enter_url,
                                            type: :one_money,
                                            winners_num: 50})

    @one_money = OneMoney[one_money_id]
    if options[:type] == :one_money
      scripts = Settings.promotions.one_money.scripts.publish
    elsif options[:type] == :daily_cheap
      scripts = Settings.promotions.daily_cheap.scripts.publish
    else
      scripts = Settings.promotions.one_money.scripts.publish
    end

    dir = scripts.dir
    exec = scripts.exec

    context = {
      name: target,
      one_money_id: @one_money.id,
      qrcode: options[:qr_code],
      home_img: @one_money.cover_url,
      list_img: @one_money.head_url,
      api_url: options[:api_url],
      winners: options[:winners_num],
      sign_url: options[:sign_url],
      prefix: options[:prefix]
    }

    exec.gsub! /\$(\w+)/ do |m|
      key = $1.to_sym
      context[key]
    end

    Rails.logger.info exec

    `cd #{dir}; #{exec}`
    store url: File.join(options[:prefix], target)
  end
end
