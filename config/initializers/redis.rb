require 'connection_pool'
# require 'em-synchrony/lib/em-synchrony/redis'
require "em-synchrony"
require "em-synchrony/em-hiredis"

EventMachine.synchrony do
  redis_config = Rails.application.config.redis_config
  host = redis_config["host"]
  port = redis_config["port"]
  db = redis_config["db"] || '0'
  auth = redis_config['auth'] ? ":#{redis_config['auth']}@" : ''
  url = "redis://#{auth}#{host}:#{port}/#{db}"
  Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
    # EventMachine::Hiredis.connect(:host => host, :port => port) }
    EventMachine::Hiredis.connect(url) }

  require 'redis_subscribe_manager'
  EM.stop
end
