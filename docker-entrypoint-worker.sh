#!/bin/bash

# Run the base entrypoint
bash /bin/docker-entrypoint.sh

# Run the installer
if [ -n "${GEM_KEY+set}" ]; then
  echo "Running the installer"
  bundle exec rails g $GEM_KEY:install
fi 

echo "--------- Starting Sidekiq in $RAILS_ENV mode ---------"
bundle exec sidekiq
