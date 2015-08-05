host = ENV['REDIS_PORT_6379_TCP_ADDR'] || 'redis://localhost:6379'

Sidekiq.configure_server do |config|
  config.redis = { url: host }
end

Sidekiq.configure_client do |config|
  config.redis = { url: host }
end
