require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module PianoServer
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    # RailsConfig::Integration::Rails::Railtie.preload
    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    # config.less.paths << "#{Rails.root}/app/assets/stylesheets"
    # config.less.compress = true
    # config.assets.paths << "#{Rails.root}/vendor/assets/fonts"
    # config.assets.precompile += %w( *.svg *.eot *.woff *.ttf )
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :put, :delete, :options]
      end
    end

    config.middleware.use 'Rack::RawUpload'

    config.i18n.load_path += Dir[Rails.root.join('config','locales', '**', '*.{rb,yml}')]
    config.i18n.default_locale = 'zh-CN'
    config.i18n.enforce_available_locales = true

    config.active_job.queue_adapter = :sidekiq
    config.api_only = false
    config.autoload_paths += %w(services drops jobs properties validators models/variables models/templates)
      .map { |_p| Rails.root.join('app', _p) }
  end
end
