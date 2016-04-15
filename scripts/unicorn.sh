#!/bin/sh
### BEGIN INIT INFO
# Provides:          unicorn
# Required-Start:    $local_fs $remote_fs mysql
# Required-Stop:     $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: unicorn initscript
# Description:       Unicorn is an HTTP server for Rack application
### END INIT INFO

# Author: Troex Nevelin <troex@fury.scancode.ru>
# based on http://gist.github.com/308216 by http://github.com/mguterl

# A sample /etc/unicorn/my_app.conf, only RAILS_ROOT is required, other are optional
#
RAILS_ENV=production
RAILS_ROOT=/var/www/PianoServer
PID=$RAILS_ROOT/tmp/pids/unicorn.pid
START_CMD="bundle exec unicorn_rails"
USER="root"
RESTART_SLEEP=5
## HANDLE_DELAYED_JOB=true

# A recommended /etc/unicorn/my_app.unicorn.rb
#
## APP_ROOT  = ENV["RAILS_ROOT"]
## RAILS_ENV = ENV["RAILS_ENV"]
##
## pid         "#{APP_ROOT}/tmp/pids/unicorn.pid"
## listen      "#{APP_ROOT}/tmp/sockets/unicorn.sock"
## stderr_path "#{APP_ROOT}/log/unicorn_error.log"
##
## working_directory "#{APP_ROOT}"
## worker_processes 1
export SECRET_KEY_BASE="XXX"
export LIVE_KEY_BASE="XXX"
export INSTANCE_ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`

export DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $INSTANCE_ID { print \$5 }'`
export DATABASE_PORT=5432
export RAILS_ENV=production

#!/bin/sh
#
# init.d script for single or multiple unicorn installations. Expects at least one .conf
# file in /etc/unicorn
#
# Modified by jay@gooby.org http://github.com/jaygooby
# based on http://gist.github.com/308216 by http://github.com/mguterl
#
## A sample /etc/unicorn/my_app.conf
##
## RAILS_ENV=production
## RAILS_ROOT=/var/apps/www/my_app/current
#
# This configures a unicorn master for your app at /var/apps/www/my_app/current running in
# production mode. It will read config/unicorn.rb for further set up.
#
# You should ensure different ports or sockets are set in each config/unicorn.rb if
# you are running more than one master concurrently.
#
# If you call this script without any config parameters, it will attempt to run the
# init command for all your unicorn configurations listed in /etc/unicorn/*.conf
#
# /etc/init.d/unicorn start # starts all unicorns
#
# If you specify a particular config, it will only operate on that one
#
# /etc/init.d/unicorn start /etc/unicorn/my_app.conf

set -e

sig () {
  test -s "$PID" && kill -$1 `cat "$PID"`
}

oldsig () {
  test -s "$OLD_PID" && kill -$1 `cat "$OLD_PID"`
}

cmd () {

  case $1 in
    start)
      sig 0 && echo >&2 "Already running" && exit 0
      echo "Starting"
      $CMD
      ;;
    stop)
      sig QUIT && echo "Stopping" && exit 0
      echo >&2 "Not running"
      ;;
    force-stop)
      sig TERM && echo "Forcing a stop" && exit 0
      echo >&2 "Not running"
      ;;
    restart|reload)
      sig USR2 && sleep 5 && oldsig QUIT && echo "Killing old master" `cat $OLD_PID` && exit 0
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      sig USR2 && echo Upgraded && exit 0
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
            sig USR1 && echo rotated logs OK && exit 0
            echo >&2 "Couldn't rotate logs" && exit 1
            ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|upgrade|rotate|force-stop>"
      exit 1
      ;;
    esac
}

setup () {

  echo -n "$RAILS_ROOT: "
  cd $RAILS_ROOT || exit 1
  export PID=$RAILS_ROOT/tmp/pids/unicorn.pid
  export OLD_PID="$PID.oldbin"

  CMD="bundle exec unicorn_rails -c config/unicorn.rb -E $RAILS_ENV -D"
}

start_stop () {

  # either run the start/stop/reload/etc command for every config under /etc/unicorn
  # or just do it for a specific one

  # $1 contains the start/stop/etc command
  # $2 if it exists, should be the specific config we want to act on
  if [ $2 ]; then
    . $2
    setup
    cmd $1
  else
    for CONFIG in config/unicorn.*.conf; do
      # import the variables
      . $CONFIG
      setup

      # run the start/stop/etc command
      cmd $1
    done
   fi
}

ARGS="$1 $2"
start_stop $ARGS
