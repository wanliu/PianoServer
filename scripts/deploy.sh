#!/bin/sh

function aws_label() {
  echo `aws ec2 describe-tags --filters "Name=key,Values=$2" | awk '\$3 = $1 { print \$5 }'`
}

function current_aws_id() {
  echo `wget -q -O - http://instance-data/latest/meta-data/instance-id`
}

export SECRET_KEY_BASE="XXX"
export LIVE_KEY_BASE="XXX"
export INSTANCE_ID=current_aws_id

export DATABASE_HOST=`aws_label $INSTANCE_ID "PostgresHost"`
export DATABASE_PORT=5432
export RAILS_ENV=production

export ELASTICSEARCH_URL=`aws_label $INSTANCE_ID "ElasticsearchUrl"`

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo "Database Host: $DATABASE_HOST"

rbenv local 2.2.4

# if [ ! -f config/settings.yml ]; then
#   cp config/settings.yml.example
#   echo "File not found!"
# fi

sed -i -e "
  /^elasticsearch:$/ {
    n
    :start
    /\n[a-zA-Z0-9]*:/! {
      N
      b start
    }
    s/url: [a-zA-Z0-9\.\:\/]*/url: `$ELASTICSEARCH_URL`/p
  }
" config/settings.yml

PREFIX="bundle exec"
bundle install

$PREFIX rake db:migrate && rake assets:clean
$PREFIX rake assets:precompile

$DIR/init.sh upgrade
