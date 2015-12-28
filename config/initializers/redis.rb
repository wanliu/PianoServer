require 'connection_pool'
# require 'em-synchrony/lib/em-synchrony/redis'
# require "em-synchrony"
# require "em-synchrony/em-redis"

redis_config = Rails.application.config.redis_config
host = redis_config["host"]
port = redis_config["port"]

Redis::Objects.redis = ConnectionPool.new(size: 5, timeout: 5) {
  conn = Redis.new driver: :hiredis, host: host, port: port
  conn
}

require 'redis_subscribe_manager'
