
export SECRET_KEY_BASE=xxx
export LIVE_KEY_BASE=gawgewaqgegag456t4jt1re56j46rk5r1mw1hg65r46t3w1her1w56t4z1v4g44rt4re445aaa
export RAILS_SERVE_STATIC_FILES=true

PORT=6000
UNICORN_CONFIG=config/unicorn.rb
rails_app=bundle exec unicorn_rails -E production -c $(UNICORN_CONFIG) -p $(PORT) -D
LOG=$(shell date +'%s')
PROFILE=

ifdef profile
	PROFILE:=--profile $(profile)
endif

quick_start:
	$(rails_app)

stop:
	kill -TERM $(shell cat tmp/pids/unicorn.pid)

restart: stop quick_start

sync_config:
	@aws s3 cp s3://wanliu/config/settings.local.yml config/settings.local.yml

bundle:
	@bundle install

migrate:
	@bundle exec rake db:migrate

launch: bundle migrate restart

clearasset:
	@echo 'clean all assets'
	@rm -rf public/assets

precompile: clearasset
	@echo 'starting precompile all assets'
	@bundle exec rake assets:clean
	@bundle exec rake assets:precompile

package: precompile
	@echo 'package all files to /tmp/deploy-piano-server-$(LOG).tar.gz'
	@tar --exclude=tmp/ --exclude=.git --exclude=log/ --exclude=.sites/ --exclude public/uploads/ --exclude public/one_money/ -czf /tmp/deploy-piano-server-$(LOG).tar.gz .

upload: package
	# Created /tmp/deploy-piano-server-$(LOG).tar.gz
	aws s3 cp /tmp/deploy-piano-server-$(LOG).tar.gz s3://wxapps $(PROFILE)
