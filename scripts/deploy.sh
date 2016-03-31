#!/bin/sh

export SECRET_KEY_BASE="XXX"
export LIVE_KEY_BASE="XXX"
export INSTANCE_ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`

export DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $INSTANCE_ID { print \$5 }'`
export DATABASE_PORT=5432
export RAILS_ENV=production

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Database Host: $DATABASE_HOST"

rbenv local 2.2.4

PREFIX="bundle exec"
bundle install

$PREFIX rake db:migrate && rake assets:clean
$PREFIX rake assets:precompile

$DIR/init.sh upgrade
