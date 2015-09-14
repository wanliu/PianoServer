#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

app_id = ENV['weixin_open_id']
app_secret = ENV['weixin_secret']
$weixin_client = WeixinAuthorize::Client.new(app_id, app_secret)
