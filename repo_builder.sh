#!/bin/bash

while getopts gemkey:gemsrc: option; do
  case ${option} in
  gemkey) GEM_KEY=${OPTARG};;
  gemsrc) GEM_SOURCE=${OPTARG};;
  esac
done

# Assume you have created/added a private key for $USER and added it to $GEM_SOURCE"
# TODO: Did not handle private key
if [ -n "${GEM_KEY+set}" ]; then
  git clone $GEM_SOURCE/$GEM_KEY.git ./vendor/$GEM_KEY

  # Insert gem if set and not already in the Gemfile
  if ! grep -q "$GEM_KEY" "Gemfile"; then
    echo -e "\ngem '"$GEM_KEY"', :path => 'vendor/"$GEM_KEY"'" >> Gemfile
  fi

else
  echo 'GEM_KEY not set'
fi