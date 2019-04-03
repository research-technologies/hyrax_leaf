#!/bin/bash

echo "Running the base entrypoint"

echo "Creating pids folders"
mkdir -p $PIDS_PATH

if [[ "$RAILS_ENV" == "production" ]]; then
    echo 'RAILS_ENV is production, running bundle check'
    # Verify all the production gems are installed
    bundle check
else
    echo 'RAILS_ENV is not production, installing dev and test dependencies'
    bundle check || bundle install --without production
fi
