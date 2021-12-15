#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron

echo "cron pg_dump log: $(date)" >> /tmp/cron.txt

DEPLOY_ENV=$1
if [ -z ${DEPLOY_ENV} ]; then
    # points to s3 bucket name
    echo "Error: no deploy env / s3 bucket input: {dev|production}"
    exit 1
fi

PG_DB_NAME=prod
PG_SERVICE_NAME=pg1
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
DATEFILE=$(date +'%Y%m%d-%H-%M')
S3_BACKUP_REPO=s3://abrepo-$DEPLOY_ENV-pg1-backups/    # DEPLOY_ENV arg passed by cron
SQL_FILENAME="abrepo-$DATEFILE.pgsql.gz"

# logical backup
docker exec -t $CONTAINER sh -c \
       "pg_dump -h pg1 -U postgres -w -Fc $PG_DB_NAME" | gzip > /tmp/$SQL_FILENAME

# aws upload to s3
aws s3 cp /tmp/$SQL_FILENAME $S3_BACKUP_REPO

# cleanup
rm /tmp/$SQL_FILENAME
