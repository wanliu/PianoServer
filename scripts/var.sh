#!/bin/sh

export SECRET_KEY_BASE="XXX"
export LIVE_KEY_BASE="XXX"
export INSTANCE_ID=`wget -q -O - http://instance-data/latest/meta-data/instance-id`

export DATABASE_HOST=`aws ec2 describe-tags --filters "Name=key,Values=PostgresHost" | awk '\$3 = $INSTANCE_ID { print \$5 }'`
export DATABASE_PORT=5432
export RAILS_ENV=production
