FROM postgres:11-alpine

COPY docker-healthcheck.sh /usr/local/bin/

COPY docker-entrypoint-initdb.d/ docker-entrypoint-initdb.d/

HEALTHCHECK CMD ["docker-healthcheck.sh"]

# RUN bash -c " PGPASSWORD=$POSTGRES_PASSWORD psql -U root -h 127.0.0.1 root -c \"CREATE INDEX index_qa_local_authority_entries_on_lower_label ON qa_local_authority_entries (local_authority_id, lower(label));\""
