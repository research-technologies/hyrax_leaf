#!/bin/bash

export APPLICATION_KEY="hull_culture"
echo "Running rails command"
echo $APPLICATION_KEY
# cd $APPLICATION_KEY

bundle install --without development test
# remove anything not in Gemfile
bundle clean --force

# TODO: Is the sed command needed?
# sed -i "s/gem 'iiif_manifest', '~> 0.3.0'/gem 'iiif_manifest', '~> 0.4.0'/g" Gemfile
bundle update iiif_manifest --conservative
bundle update devise --conservative

# TODO: psql is only available in db container
# add the qa index as per https://github.com/samvera/questioning_authority
# echo 'Add the index to the database'
# bash -c " PGPASSWORD=$POSTGRES_PASSWORD psql -U $USER -h 127.0.0.1 $USER -c \"CREATE INDEX index_qa_local_authority_entries_on_lower_label ON qa_local_authority_entries (local_authority_id, lower(label));\""
