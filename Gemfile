source 'https://ruby.taobao.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
gem "rails-api"

# Use sqlite3 as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails'
#gem 'sassc-rails'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# gem "therubyracer", :platforms => :ruby

gem 'jbuilder', '~> 2.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# gem "libv8"

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# 前端库
# gem "less-rails" #Sprockets (what Rails 3.1 uses for its asset pipeline) supports LESS
gem 'bootstrap-sass', '~> 3.3.5'
gem 'nprogress-rails'
gem 'momentjs-rails', '>= 2.9.0'
gem 'bootstrap3-datetimepicker-rails', '~> 4.15.35'
gem 'ace-rails-ap'
gem 'best_in_place', '~> 3.0.1'
gem 'bootsy'
gem 'jquery-turbolinks'
gem 'photoswipe-rails', '~> 4.1.0'
gem 'bh', '~> 1.3'
gem "slim-rails"
gem "select2-rails"
gem 'picturefill'

# 后端库
gem 'activeresource'
gem 'scoped_search'
gem 'json-patch'
gem 'hashdiff'
gem 'chinese_pinyin'
gem 'data-confirm-modal', github: 'ifad/data-confirm-modal'
gem 'liquid-rails'
gem "punching_bag"
gem "loofah-activerecord"
gem 'public_activity', github: 'pokonski/public_activity'
gem 'rails-observers', git: 'https://github.com/rails/rails-observers.git'
gem 'composite_primary_keys'

gem 'elasticsearch-model'
gem 'elasticsearch-rails'
gem 'elasticsearch-persistence'
gem 'actionpack-page_caching'
gem 'redis-rails'
gem 'oj'
gem 'oj_mimic_json'
# gem 'active_model_serializers', github: 'rails-api/active_model_serializers', tag: 'v0.10.0.rc2'

# 中间件
gem 'rack-cors', :require => 'rack/cors'
gem 'rack-raw-upload', '~> 1.1.1'
gem 'rack-attack', require: 'rack/attack'

gem 'devise', '3.4.0'
gem 'devise-async'
gem 'mobylette'
# gem 'nio4r'
gem "mini_magick", '~> 4.2.7'

gem 'poseidon'
gem 'google-analytics-rails'
gem 'kaminari'
gem 'awesome_nested_set'
gem 'ancestry' # 暂时的支持，旧的 neil

gem "rails_config", '~> 0.4.2'

gem 'jwt'

gem 'rest-client'

gem 'meta-tags'

gem 'sidekiq'

gem 'china_city'
gem 'table_cloth'

gem 'oneapm_rpm' if ENV['USE_RPM']

gem 'carrierwave', github: 'hysios/carrierwave', branch: 'mount-multiple'
gem 'carrierwave-upyun', "0.2.1"
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
gem 'unicorn'
# gem 'puma'
# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

gem 'weixin_authorize'
gem "omniauth-wechat-oauth2"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'guard-rails'
  gem 'guard-rspec', require: false
  gem 'guard-sidekiq'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'

  gem 'rspec-rails', '~> 3.0'
  gem 'i18n-debug' if ENV['I18N_DEBUG']
  gem 'quiet_assets' if ENV['ENABLE_ASSETS_LOG']
  gem 'rails-backup-migrate'

  gem 'factory_girl_rails'
  gem 'thin'
  gem "teaspoon-jasmine"
  gem 'spring-commands-teaspoon'
  gem "table_print"
end
