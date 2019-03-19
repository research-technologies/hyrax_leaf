#!/bin/bash

echo "Running the base entrypoint"

echo "Creating pids folders"
mkdir -p $PIDS_PATH

if [ "$RAILS_ENV" EQ "production" ]; then
    echo 'Not doing it'
    # Verify all the production gems are installed
    bundle check
else
    # install any missing development gems (as we can tweak the development container without rebuilding it)
    bundle check || bundle install --without production
fi

# Run any pending migrations
bundle exec rake db:migrate
