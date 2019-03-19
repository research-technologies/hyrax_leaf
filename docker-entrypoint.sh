#!/bin/bash

echo "Running the base entrypoint"

echo "Creating pids folders"
mkdir -p $PIDS_PATH/sockets $PIDS_PATH/pids

if [ "$RAILS_ENV" = "production" ]; then
    # Verify all the production gems are installed
    bundle check
    # Remove any unused gems
    bundle clean --force
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

# Run any pending migrations
bundle exec rake db:migrate
