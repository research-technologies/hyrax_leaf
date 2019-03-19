#!/bin/bash

# Run the base entrypoint
bash /bin/docker-entrypoint.sh

FLAG=""
if [ ! -f $APP_WORKDIR/shared/.gem_installed ]; then
    echo "Setting the initial flag"
    FLAG=" --initial"
    touch $APP_WORKDIR/shared/.gem_installed
fi

# Solr / Fedora need to be running for initial setup only
if [ "$FLAG" = "--initial"]; then 
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
fi

# With the --initial flag, the install generator runs the setup rake tasks
if [ -n "${GEM_KEY+set}" ]; then
  echo "Running the installer"
  bundle exec rails g $GEM_KEY:install $FLAG
# If the GEM_KEY isn't set on the initial run; run the setup tasks
elif [ ! -n "${GEM_KEY+set}" ] && [ "$FLAG" == "--initial" ] ; then
  echo "Running the setup tasks"
  bundle exec rake assets:clean assets:precompile
  bundle exec rake hyrax:default_admin_set:create
  bundle exec rake hyrax:workflow:load
  bundle exec rake hyrax:default_collection_types:create
else
  echo "Check for new assets"
  bundle exec rake assets:clean assets:precompile
fi 

echo "--------- Starting Hyrax in $RAILS_ENV mode ---------"
bundle exec rails server -p $RAILS_PORT -b '0.0.0.0' --pid $PIDS_PATH/pids/$APPLICATION_KEY.pid