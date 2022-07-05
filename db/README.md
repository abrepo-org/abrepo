# Database Backups

Because DB is run in bitnami container with its internal startup
scripts, restore process is a bit of a nuisance.

These operations have hardcoded release paths and container images
`docker run` - a bit of a mess -so make sure to upgrade containers,
paths accordingly.

## Restore

Generally Speaking, on a fresh instance (e.g. staging) restore is
tricky. The key is to run pg1 without the internal scripts removing
`recovery.signal`, which is done with our hacky override `run.sh`.

These typically need a fresh **running** container for `docker exec`
operations to pull container ids.

1. create stanza: `backup_createstanza_pgbackrest.sh`
  * repo 1 - /mnt/pgbackrest
  * repo 2 - s3
2. Run sequence of restore operations
  * `./restore_pgbackrest_1.sh`: pgbackrest pulls from s3
  * `./restore_pgbackrest_2.sh`: starts pg container with `run.sh`
    that preserves `recovery.signal`. Cntrl-C out of db. <-- THIS IS THE KEY STEP IF DIFFICULTY RESTARTING DB. make sure to run via `run.sh` in this script.
  * `./restore_pgbackrest)3.sh`: cleans up and restarts service

## Switching Repo

Sometimes want to pull from prod to local dev

1. Comment out `./archive.conf`, `./run.sh`
2. Restore
3. mount to `./run.sh` to enable restore
4. export PGBACKREST_REPO2_S3_BUCKET=abrepo-dev-pg1-pgbackrest
5. create stanza, then exit
6. recomment ./run.sh and restart pg1
7. should be set to fresh backup to -dev bucket
