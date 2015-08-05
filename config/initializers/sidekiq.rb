redis_config = YAML.load(ERB.new(File.read("#{Rails.root}/config/redis.yml")).result)[Rails.env]
Sidekiq.configure_server do |config|
  config.redis = {url: "redis://#{redis_config['host']}:#{redis_config['port']}"}
end
Sidekiq.configure_client do |config|
  config.redis = {url: "redis://#{redis_config['host']}:#{redis_config['port']}"}
end
