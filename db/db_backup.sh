#!/usr/bin/env bash
# NB: need to disable interactive terminal (-i) in docker exec when run by cron

echo "cron db backups log: $(date)" >> /tmp/cron.txt

DEPLOY_ENV=$1
if [ -z ${DEPLOY_ENV} ]; then
    # points to s3 bucket name
    echo "Error: no deploy env / s3 bucket input: e.g. {development|staging|production..}"
    exit 1
fi

PG_DB_NAME=prod
CONTAINER=$(docker ps --filter name=pg -q)
DATEFILE=$(date +'%Y%m%d-%H-%M')

#
# logical backup
#
SQL_FILENAME="abrepo-$DATEFILE.sql.gz"
docker exec -t $CONTAINER sh -c "pg_dump -h pg1 -U postgres -w -Fp $PG_DB_NAME" | gzip > /tmp/$SQL_FILENAME

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
# aws separate output to DEPLOY_ENV bucket, arg passed by cron
aws s3 cp /tmp/$SQL_FILENAME s3://ab-db-backups-$DEPLOY_ENV/
aws s3 cp /tmp/$BASEBACKUP_FILENAME s3://ab-db-backups-$DEPLOY_ENV/

#cleanup
rm /tmp/$BASEBACKUP_FILENAME
