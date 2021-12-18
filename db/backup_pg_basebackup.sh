#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron
#
# pg_basebackup currently disabled for now
# requires pg replication setup

echo "cron pg_basebackup log: $(date)" >> /tmp/cron.txt

DEPLOY_ENV=$1
if [ -z ${DEPLOY_ENV} ]; then
    # points to s3 bucket name
    echo "Error: no deploy env / s3 bucket input: {dev|production}"
    exit 1
fi

echo "requires setup of replication user in pg_hba.conf to run"
echo "set replication in pg1"
exit 1

PG_DB_NAME=abrepo_www_prod
PG_SERVICE_NAME=pg1
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
DATEFILE=$(date +'%Y%m%d-%H-%M')
S3_BACKUP_REPO=s3://abrepo-$DEPLOY_ENV-pg1-backups/    # DEPLOY_ENV arg passed by cron


# /tmpdb is a bind mount to /tmp
#
# pg_basebackup requires seting up a replication user / config in
# pg_hba.conf which can be done enabling bitnami master replication

BASEBACKUP_FILENAME="abrepo-$DATEFILE.tar.gz"

docker exec -t $CONTAINER sh -c \
       "pg_basebackup -h pg1 -U postgres -w -Fp -D /tmpdb/$PG_DB_NAME" \
       tar -zcvf /tmp/$BASEBACKUP_FILENAME /tmp/$PG_DB_NAME

# aws upload to s3
aws s3 cp /tmp/$BASEBACKUP_FILENAME $S3_BACKUP_REPO

#cleanup
rm /tmp/$BASEBACKUP_FILENAME
