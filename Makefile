
export SECRET_KEY_BASE=xxx
export LIVE_KEY_BASE=gawgewaqgegag456t4jt1re56j46rk5r1mw1hg65r46t3w1her1w56t4z1v4g44rt4re445aaa
export RAILS_SERVE_STATIC_FILES=true

PORT=6000
UNICORN_CONFIG=config/unicorn.rb
rails_app=bundle exec unicorn_rails -E production -c $(UNICORN_CONFIG) -p $(PORT) -D

quick_start:
	$(rails_app)

stop:
	kill -TERM $(shell cat tmp/pids/unicorn.pid)

restart: stop quick_start

