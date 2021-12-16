#!/usr/bin/env bash

echo "pg_backrest restore: $(date)" >> /tmp/cron.txt

PG_DB_NAME=prod
PG_SERVICE_NAME=pg1
STANZA='prod_db_stanza'

# default to repo2 (from s3.) Having trouble with repo1 perms -use backup_pgbackrest.sh
REPO=2

# 1. Get env variables
# get PGBACKREST env variables from container and remove single quotes
echo "Grab PGBACKREST env vars"
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
docker exec -t $CONTAINER sh -c 'set | grep PGBACKREST' > .env.pg1
sed -i -E  "s/'//g" .env.pg1

# 2. shutdown
echo "shutting down pg1"
docker service scale abrepo_pg1=0
sleep 10

# 3. RESTORE
# use --env-file .env.pg1 from step 1
echo "restore operation repo=$REPO"

docker run -i \
       -v /tmp:/tmpdb \
       -v /mnt/abrepo_pg1data:/bitnami/postgresql \
       -v /root/releases/abrepo/db/pgbackrest.conf:/etc/pgbackrest.conf \
       --env-file=.env.pg1 \
       bitnami/postgresql \
       sh -c "pgbackrest --stanza=prod_db_stanza --repo=$REPO --delta restore"

# 4. Restart
# there should be visible log output of successful restore
echo "restarting pg1"
rm .env.pg1
docker service scale abrepo_pg1=1
sleep 10

# 5. Create stanza
CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
docker exec -t $CONTAINER sh -c 'pgbackrest --stanza=prod_db_stanza stanza-create'

# 6. Backup sync
docker exec -t $CONTAINER sh -c 'pgbackrest --stanza=prod_db_stanza --repo=1 backup'
