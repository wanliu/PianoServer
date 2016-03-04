#!/bin/sh

ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`
DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $ID  { print \$5 }'`
DATABASE_PORT=5432
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
RAILS_ENV=production
bundle exec rake db:migrate && rake assets:clean
bundle exec rake assets:precompile

$DIR/init.sh upgrade
