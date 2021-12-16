#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron
set -x

echo "pg_backrest backup: $(date)" >> /tmp/cron.txt

PG_DB_NAME=prod
PG_SERVICE_NAME=pg1
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)

DEPLOY_ENV=$1
STANZA=$2
TYPE=$3
REPO=$4

#
# job: "pgbackrest --stanza=prod_db_stanza --type=diff --repo=1 backup"
#
BACKUP_CMD="pgbackrest --stanza=$STANZA --type=$TYPE --repo=$REPO backup"

echo "docker exec -t $CONTAINER sh -c '$BACKUP_CMD'"

docker exec -t $CONTAINER sh -c "$BACKUP_CMD"
