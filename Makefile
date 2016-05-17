NAME=PianoServer
export SECRET_KEY_BASE=xxx
export LIVE_KEY_BASE=gawgewaqgegag456t4jt1re56j46rk5r1mw1hg65r46t3w1her1w56t4z1v4g44rt4re445aaa
export RAILS_SERVE_STATIC_FILES=true
export RAILS_ENV=production

PORT=6000
UNICORN_CONFIG=config/unicorn.rb
rails_app=bundle exec unicorn_rails -E production -c $(UNICORN_CONFIG) -p $(PORT) -D
LOG:=$(shell date +'%s')
PROFILE=
WATCH=
PIPE=$(pipe)

ifeq ($(PIPE),1)
	LOGNAME:=$(NAME)
endif

ifeq ($(PIPE),2)
	LOGNAME:=sidekiq_pianoserver
endif

ifndef pipe
	LOGNAME:=$(NAME)
endif

ifdef profile
	PROFILE:=--profile $(profile)
endif

ifdef watch
	WATCH:=--watch
endif


AWSLOGS:=$(shell awslogs -h 2> /dev/null)

.PHONY: log
log:
ifndef AWSLOGS
	$(error "awslogs is not available please install https://github.com/jorgebastida/awslogs")
endif
	awslogs get $(LOGNAME) $(WATCH) $(PROFILE)

wlog:
ifndef AWSLOGS
	$(error "awslogs is not available please install https://github.com/jorgebastida/awslogs")
endif
	awslogs get $(LOGNAME) --watch $(PROFILE)

quick_start:
	@echo 'launch unicorn_rails $(NAME)...'
	@$(rails_app)

stop:
	@echo 'stop unicorn_rails $(NAME)'
	-@kill -TERM $(shell cat tmp/pids/unicorn.pid)

restart: stop quick_start

sync_config:
	@aws s3 cp s3://wanliu/config/piano/settings.local.yml config/settings.local.yml $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat_access_token /var/tmp/wechat_access_token $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat_jsapi_ticket /var/tmp/wechat_jsapi_ticket $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat.yml config/wechat.yml $(PROFILE)

bundle:
	@bundle install

migrate:
	@bundle exec rake db:migrate

launch: sync_config bundle migrate restart sidekiq schedule

sidekiq:
	@-test -s tmp/pids/sidekiq.pid && kill -TERM `cat tmp/pids/sidekiq.pid`
	@bundle exec sidekiq -d

schedule:
	@bundle exec whenever -iw

clearasset:
	@echo 'clean all assets'
	@rm -rf public/assets

precompile: clearasset
	@echo 'starting precompile all assets'
	@bundle exec rake assets:clean
	@bundle exec rake assets:precompile

package:
	@echo 'package all files to /tmp/deploy-piano-server-$(LOG).tar.gz'
	@tar --exclude=tmp/ --exclude=.git --exclude=log/ --exclude=.sites/ --exclude public/uploads/ --exclude public/one_money/ -czf /tmp/deploy-piano-server-$(LOG).tar.gz .

upload: package
	@echo 'Created /tmp/deploy-piano-server-$(LOG).tar.gz'
	aws s3 cp /tmp/deploy-piano-server-$(LOG).tar.gz s3://wxapps $(PROFILE)

deploy: precompile package upload
