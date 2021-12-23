#!/usr/bin/env bash

echo "pg_backrest restore_pgbackrest_3: $(date)" >> /tmp/cron.txt

# 4. Restart
# there should be visible log output of successful restore
echo "restarting pg1"
rm .env.pg1
docker service scale abrepo_pg1=1
sleep 10

echo "If prod, make sure stanza and backup sync"

# 5. Create stanza
# CONTAINER=$(docker ps --filter name=$PG_SERVICE_NAME -q)
# docker exec -t $CONTAINER sh -c 'pgbackrest --stanza=prod_db_stanza stanza-create'

# 6. Backup sync
# docker exec -t $CONTAINER sh -c 'pgbackrest --stanza=prod_db_stanza --repo=1 backup'
