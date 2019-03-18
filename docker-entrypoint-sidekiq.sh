#!/bin/bash

echo "Creating pids folders"
mkdir -p $PIDS_PATH/pids

if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

# Run the installer without any flag
if [ -n "${GEM_KEY+set}" ]; then
  echo "Running the installer"
  bundle exec rails g $GEM_KEY:install
fi 

echo "--------- Starting Sidekiq in $RAILS_ENV mode ---------"
bundle exec sidekiq
