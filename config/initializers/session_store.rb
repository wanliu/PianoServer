# Be sure to restart your server when you modify this file.

Rails.application.config.session_store :cookie_store, key: '_PianoServer_session', :expire_after => 259200, :domain => :all

# options = {
#   key: '_PianoServer_session',
#   redis: {
#     db: 2,
#     expire_after: 3.days,
#     key_prefix: 'piano:session:',
#     host: Rails.application.config.redis_config["host"], # Redis host name, default is localhost
#     port: Rails.application.config.redis_config["port"]   # Redis port, default is 6379
#   }
# }

# if Rails.env.production?
#   options[:domain] = ".wanliu.biz"
# end

# Rails.application.config.session_store :redis_session_store, options
