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
      sig 0 && echo >&2 "Already running" && return
      echo "Starting"
      $CMD
      ;;
    stop)
      sig QUIT && echo "Stopping" && return
      echo >&2 "Not running"
      ;;
    force-stop)
      sig TERM && echo "Forcing a stop" && return
      echo >&2 "Not running"
      ;;
    restart|reload)
      sig USR2 && sleep $RESTART_SLEEP && oldsig QUIT && echo "Killing old master" `cat $OLD_PID` && return
      echo >&2 "Couldn't reload, starting '$CMD' instead"
      $CMD
      ;;
    upgrade)
      sig USR2 && echo Upgraded && return
      echo >&2 "Couldn't upgrade, starting '$CMD' instead"
      $CMD
      ;;
    rotate)
      sig USR1 && echo rotated logs OK && return
      echo >&2 "Couldn't rotate logs" && return
      ;;
    status)
      sig 0 && echo >&2 "Already running" && return
      echo >&2 "Not running" && return
      ;;
    *)
      echo >&2 "Usage: $0 <start|stop|restart|reload|status|upgrade|rotate|force-stop>"
      return
      ;;
    esac
}

setup () {
  echo -n "$RAILS_ROOT: "
  cd $RAILS_ROOT || exit 1

  if [ -z "$RAILS_ENV" ]; then
    RAILS_ENV=development
  fi

  if [ -z "$PID" ]; then
    PID=$RAILS_ROOT/tmp/pids/unicorn.pid
  fi

  if [ -z "$RESTART_SLEEP" ]; then
    RESTART_SLEEP=5
  fi

  export PID
  export OLD_PID="$PID.oldbin"
  export RAILS_ROOT
  export RESTART_SLEEP

  if [ -z "$START_CMD" ]; then
    START_CMD="bundle exec unicorn_rails"
  fi
  CMD="$START_CMD -c $UNICORN_CONFIG -E $RAILS_ENV -D"

  if [ "$USER" != `whoami` ]; then
    CMD="sudo -u $USER -- env RAILS_ROOT=$RAILS_ROOT $CMD"
  fi
  export CMD
  #echo $CMD
}

handle_delayed_job () {
  # $1 contains command
  if [ "$HANDLE_DELAYED_JOB" != "true" ]; then
    return
  fi

  case $1 in
    start|stop|restart|reload|status)
      CMD="env RAILS_ENV=$RAILS_ENV bundle exec ./script/delayed_job $1"
      if [ "$USER" != `whoami` ]; then
        CMD="sudo -u $USER -- env $CMD"
      fi
      $CMD
    ;;
  esac
}

start_stop () {
  # either run the start/stop/reload/etc command for every config under /etc/unicorn
  # or just do it for a specific one

  # $1 contains the start/stop/etc command
  # $2 if it exists, should be the specific config we want to act on
  if [ -n "$2" ]; then
    if [ -f "/etc/unicorn/$2.conf" ]; then
      . /etc/unicorn/$2.conf
      export UNICORN_CONFIG="/etc/unicorn/$2.unicorn.rb"
      setup
      cmd $1
      handle_delayed_job $1
    else
      echo >&2 "/etc/unicorn/$2.conf: not found"
    fi
  else
    for CONFIG in /etc/unicorn/*.conf; do
      # import the variables
      export UNICORN_CONFIG=`echo ${CONFIG} | sed 's/conf/unicorn.rb/'`
      . $CONFIG
      setup

      # run the start/stop/etc command
      cmd $1
      handle_delayed_job $1

      # clean enviroment
      unset PID
      unset OLD_PID
      unset RAILS_ROOT
      unset RAILS_ENV
      unset CMD
      unset USER
      unset START_CMD
      unset UNICORN_CONFIG
    done
   fi
}

ARGS="$1 $2"
start_stop $ARGS
