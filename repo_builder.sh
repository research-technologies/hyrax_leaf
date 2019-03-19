#!/bin/bash

GEM_KEY=$(echo $GEM_KEY)
GEM_SOURCE=$(echo $GEM_SOURCE)

# Assume you have created/added a private key for $USER and added it to $GEM_SOURCE"
# TODO: Did not handle private key
if [ -n "${GEM_KEY+set}" ]; then
  echo 'GEM_KEY is set, adding gem';
  git clone $GEM_SOURCE/$GEM_KEY.git ./vendor/$GEM_KEY
  # Insert gem if set and not already in the Gemfile
  if ! grep -q "$GEM_KEY" "Gemfile"; then
    echo -e "\ngem '"$GEM_KEY"', :path => 'vendor/"$GEM_KEY"'" >> Gemfile ;
  fi
else
  echo 'GEM_KEY not set';
fi