#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron
#
# This is now incorporated into backup_pgbackrest.sh - will run before
# each backup
#
set -x

echo "pg_backrest create stanza: $(date)" >> /tmp/cron.txt

PG_SERVICE_NAME=pg1
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)

STANZA=$1

#
# job: "pgbackrest --stanza=prod_db_stanza stanza-create"
#
BACKUP_CMD="pgbackrest --stanza=$STANZA stanza-create"

echo "docker exec -t $CONTAINER sh -c '$BACKUP_CMD'"

docker exec -t $CONTAINER sh -c "$BACKUP_CMD"
