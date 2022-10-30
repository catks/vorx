#!/bin/sh

set -e

bundle check || bundle install

./wait-for-it.sh gitserver:80 -t 10

git config --global --add safe.directory /usr/src/vorx

exec bundle exec "$@"
