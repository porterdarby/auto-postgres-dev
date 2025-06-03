FROM postgres:17.5

# This is to allow us to force a different directory so that it's not volumized.
ENV PGDATA /var/lib/postgresql/custom-data

COPY ./db/ /docker-entrypoint-initdb.d/

