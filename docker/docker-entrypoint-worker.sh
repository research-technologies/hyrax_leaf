#!/bin/bash

# Run the base entrypoint
bash /bin/docker-entrypoint.sh

echo "--------- Starting Sidekiq in $RAILS_ENV mode ---------"
SIDEKIQ_START=`bundle exec sidekiq`
if [ "$?" -ne "0" ]; then
  echo "### There was an issue starting sidekiq. We have kept this container alive for you to go and see what's up ###"
  tail -f /dev/null
fi
