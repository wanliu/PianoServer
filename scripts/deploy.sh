#!/bin/sh

ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`
export DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $ID  { print \$5 }'`
export DATABASE_PORT=5432
export RAILS_ENV=production
echo "Database Host: $DATABASE_HOST"
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PREFIX="bundle exec"

$PREFIX rake db:migrate && rake assets:clean
$PREFIX rake assets:precompile

$DIR/init.sh upgrade
