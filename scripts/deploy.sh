#!/bin/sh

ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`
DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $ID  { print \$5 }'`
DATABASE_PORT=5432
echo "Database Host: $DATABASE_HOST"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREFIX=" bundle exec "
ENV="RAILS_ENV=production"
CMD_PREFIX="DATABASE_HOST='$DATABASE_HOST' $ENV $PREFIX "

$CMD_PREFIX rake db:create 
$CMD_PREFIX rake db:migrate && rake assets:clean
$PREFIX rake assets:precompile

$DIR/init.sh upgrade
