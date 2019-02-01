#!/bin/bash

echo "Creating folders"
mkdir -p $APP_WORKDIR/log
mkdir -p $APP_WORKDIR/shared/pids
mkdir -p $APP_WORKDIR/shared/log


if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

## Run any pending migrations
bundle exec rake db:migrate

# wait for Solr and Fedora to come up
sleep 15s

# check that Solr is running
SOLR=$(curl --silent --connect-timeout 45 "http://${SOLR_HOST:-solr}:${SOLR_PORT:-8983}/solr/" | grep "Apache SOLR")
if [ -n "$SOLR" ] ; then
    echo "Solr is running..."
else
    echo "ERROR: Solr is not running"
    # exit 1
fi

# check that Fedora is running
FEDORA=$(curl --silent --connect-timeout 45 "http://${FEDORA_HOST:-fcrepo}:${FEDORA_PORT:-8080}/fcrepo/" | grep "Fedora Commons Repository")
if [ -n "$FEDORA" ] ; then
    echo "Fedora is running..."
else
    echo "ERROR: Fedora is not running"
    # exit 1
fi

bundle exec rake assets:clean assets:precompile
bundle exec rake hyrax:default_admin_set:create
bundle exec rake hyrax:workflow:load
bundle exec rake hyrax:default_collection_types:create

# echo "--------- Starting Hyrax in $RAILS_ENV mode ---------"
rm -f /tmp/hyrax.pid
bundle exec rails server -p 3000 -b '0.0.0.0' --pid /tmp/hyrax.pid
