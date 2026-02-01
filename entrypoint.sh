#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

PG_READY="pg_isready -h ${POSTGRES_HOST:-postgres} -p ${POSTGRES_PORT:-5432} -U ${POSTGRES_USERNAME:-postgres}"

until $PG_READY
do
  echo "Postgres is unavailable - sleeping"
  sleep 2;
done

echo "Database ready to accept connections."

# Run database migrations
echo "Running database migrations..."
bundle exec rails db:prepare

# Execute the main process of the container
exec "$@"
