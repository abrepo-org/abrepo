#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron
# ./backup_pgbackrest.sh production prod_db_stanza diff 2
set -x

PG_DB_NAME=abrepo_www_prod
PG_SERVICE_NAME=pg1
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)

DEPLOY_ENV=$1
STANZA=$2
TYPE=$3
REPO=$4


#
# initally make sure stanza is created
#
# job: "pgbackrest --stanza=prod_db_stanza stanza-create"
#

echo "pg_backrest create stanza: $(date) $STANZA" >> /tmp/cron.txt

STANZA_CMD="pgbackrest --stanza=$STANZA stanza-create"

echo "docker exec -t $CONTAINER sh -c '$STANZA_CMD'"

docker exec -t $CONTAINER sh -c "$STANZA_CMD"

#
# job: "pgbackrest --stanza=prod_db_stanza --type=diff --repo=1 backup"
#

echo "pg_backrest backup: $(date) $TYPE $REPO" >> /tmp/cron.txt

BACKUP_CMD="pgbackrest --stanza=$STANZA --type=$TYPE --repo=$REPO backup"

echo "docker exec -t $CONTAINER sh -c '$BACKUP_CMD'"

docker exec -t $CONTAINER sh -c "$BACKUP_CMD"
