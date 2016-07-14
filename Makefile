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
S3_STORAGE=s3://wxtest
SETTIGNS_FILE=s3://wanliu/config/piano/settings.local.test.yml

ifeq ($(PIPE),1)
	LOGNAME:=$(NAME)Log
endif

ifeq ($(PIPE),2)
	LOGNAME:=sidekiq_pianoserver
endif

ifndef pipe
	LOGNAME:=$(NAME)Log
endif

ifdef profile
	PROFILE:=--profile $(profile)
endif

ifdef watch
	WATCH:=--watch
endif

ifdef online
	S3_STORAGE:=s3://wxapps
	SETTIGNS_FILE=s3://wanliu/config/piano/settings.local.yml
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

prepare_config:
	@echo $(SETTIGNS_FILE) > Settingfile

after_config:
	@rm Settingfile

try_config:
ifneq ("$(wildcard Settingfile)","")
	$(eval SETTIGNS_FILE=$(shell cat Settingfile))
endif
	@echo $(SETTIGNS_FILE)	

sync_config: try_config
	@aws s3 cp $(SETTIGNS_FILE) config/settings.local.yml $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat_access_token /var/tmp/wechat_access_token $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat_jsapi_ticket /var/tmp/wechat_jsapi_ticket $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/apiclient_cert.p12 /var/tmp/apiclient_cert.p12 $(PROFILE)
	@aws s3 cp s3://wanliu/config/piano/wechat.yml config/wechat.yml $(PROFILE)

bundle:
	@bundle install

migrate:
	@bundle exec rake db:migrate

launch: sync_config bundle migrate precompile restart sidekiq schedule

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

package: prepare_config
	@echo 'package all files to /tmp/deploy-piano-server-$(LOG).tar.gz'
	@tar --exclude=tmp/ --exclude=.git --exclude=log/ --exclude=.sites/ --exclude public/uploads/ --exclude public/one_money/ -czf /tmp/deploy-piano-server-$(LOG).tar.gz .
	$(MAKE) after_config

upload: package
	@echo 'Created /tmp/deploy-piano-server-$(LOG).tar.gz'
	aws s3 cp /tmp/deploy-piano-server-$(LOG).tar.gz $(S3_STORAGE) $(PROFILE)

ssh:
	@aws s3 cp s3://wanliu/test.pem ~/.ssh/test.pem $(PROFILE)
	@ssh -i ~/.ssh/test.pem ec2-user@test.wanliu.biz

deploy: package upload
