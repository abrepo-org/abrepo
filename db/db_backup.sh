#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron

echo "cron db backups log: $(date)" >> /tmp/cron.txt

DEPLOY_ENV=$1
if [ -z ${DEPLOY_ENV} ]; then
    # points to s3 bucket name
    echo "Error: no deploy env / s3 bucket input: e.g. {development|staging|production..}"
    exit 1
fi

PG_SERVICE_NAME=pg
PG_DB_NAME=prod
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
DATEFILE=$(date +'%Y%m%d-%H-%M')
S3_BACKUP_REPO=s3://abrepo-$DEPLOY_ENV-pg1-backups/    # DEPLOY_ENV arg passed by cron

#
# logical backup
#
SQL_FILENAME="abrepo-$DATEFILE.pgsql.gz"
docker exec -t $CONTAINER sh -c "pg_dump -h pg1 -U postgres -w -Fc $PG_DB_NAME" | gzip > /tmp/$SQL_FILENAME

#
# basebackup
#
# NB: /tmpdb is a bind mount to /tmp
#
BASEBACKUP_FILENAME="abrepo-$DATEFILE.tar.gz"
docker exec -t $CONTAINER sh -c "pg_basebackup -h pg1 -U postgres -w -Fp -D /tmpdb/$PG_DB_NAME"
tar -zcvf /tmp/$BASEBACKUP_FILENAME /tmp/$PG_DB_NAME

#
# aws upload to s3
#
aws s3 cp /tmp/$SQL_FILENAME $S3_BACKUP_REPO
aws s3 cp /tmp/$BASEBACKUP_FILENAME $S3_BACKUP_REPO

#cleanup
rm /tmp/$SQL_FILENAME
rm /tmp/$BASEBACKUP_FILENAME
