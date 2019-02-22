#!/bin/bash

pkill -f wrapper
pkill -f solr

sleep 5

rm -rf tmp/*

solr_wrapper & fcrepo_wrapper &

rake db:drop

rails g leaf_addons:invitable

rails db:migrate

rake warburg:test_users

rake warburg:collections

rake hyrax:default_admin_set:create

rails s -b 0.0.0.0 -p 3000
