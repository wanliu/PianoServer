#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
# don't forget change namespace
namespace = "piano_weixin:weixin_authorize"
redis = Redis.new(:host => "127.0.0.1", :port => "6379", :db => 15)

# cleanup keys in the current namespace when restart server everytime.
exist_keys = redis.keys("#{namespace}:*")
exist_keys.each{|key|redis.del(key)}

# Give a special namespace as prefix for Redis key, when your have more than one project used weixin_authorize, this config will make them work fine.
redis = Redis::Namespace.new("#{namespace}", :redis => redis)

WeixinAuthorize.configure do |config|
  config.redis = redis
end

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
