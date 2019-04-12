#!/bin/bash

# Run the base entrypoint
bash /bin/docker-entrypoint.sh

bundle exec rake assets:precompile

echo "--------- Starting Sidekiq in $RAILS_ENV mode ---------"
bundle exec sidekiq
