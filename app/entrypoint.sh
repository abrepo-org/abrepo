#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /app/tmp/pids/server.pid

# init / update app - move to Dockerfile (build step)
#cd /app
#rake db:create
#rake db:migrate
#rake assets:precompile

# other startup rake tasks
#rake xyz

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
