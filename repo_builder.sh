#!/bin/bash

############################################
# This script will install and configure:  #
# - rbenv                                  #
# - hyku/hyrax                                 #
############################################

echo SETTING LOCAL VARIABLES

export GEM_KEY=hull_culture
export GEM_SOURCE=https://github.com/research-technologies
export APPLICATION_KEY=hull_culture
export APP_URL='https://github.com/research-technologies/hyrax_leaf'
export BRANCH='master'

# Assume you have created/added a private key for $USER and added it to $GEM_SOURCE"
# TODO: Did not handle private key
# TODO: Not cloning, but copying locally cloned hyrax leaf.
#       See Dockerfile line 57 to 59
# git clone $APP_URL --branch $BRANCH .
git clone $GEM_SOURCE/$GEM_KEY.git ./vendor/$GEM_KEY

# Insert gems
if ! grep -q "$GEM_KEY" "Gemfile"; then
  echo -e "\ngem '"$GEM_KEY"', :path => 'vendor/"$GEM_KEY"'" >> Gemfile
fi
