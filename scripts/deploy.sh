#!/bin/sh
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
$DIR/var.sh

echo "Database Host: $DATABASE_HOST"

PREFIX="bundle exec"

$PREFIX rake db:migrate && rake assets:clean
$PREFIX rake assets:precompile

$DIR/init.sh upgrade
