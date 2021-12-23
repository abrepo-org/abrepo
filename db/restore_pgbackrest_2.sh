#!/usr/bin/env bash

echo "pg_backrest restore_pgbackrest_2: $(date)" >> /tmp/cron.txt

# 4. PG RESTORE
# mount alternate runtime
# this is a one-time run meant to setup the database
# and be exited out

docker run -i \
       -v /tmp:/tmpdb \
       -v /mnt:/mnt \
       -v /mnt/abrepo_pg1data:/bitnami/postgresql \
       -v /root/releases/abrepo/db/pgbackrest.conf:/etc/pgbackrest.conf \
       -v /root/releases/abrepo/run.sh:/opt/bitnami/scripts/postgresql/run.sh \
       --env-file=.env.pg1 \
       bitnami/postgresql:13.5.0
