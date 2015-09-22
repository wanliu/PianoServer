#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

class WeixinClient
  include Singleton
  attr_reader :client

  def initialize
    app_id = Settings.weixin.app_id
    secret = Settings.weixin.secret

    fail if app_id.nil? or secret.nil?
    @client = WeixinAuthorize::Client.new(app_id, secret)
  end
end
