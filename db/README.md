# Database Backups

Because DB is run in bitnami container with its internal startup
scripts, restore process is a bit of a nuisance.

These operations have hardcoded release paths and container images
`docker run` - a bit of a mess -so make sure to upgrade containers,
paths accordingly.

### .env.pg1

This is used for restoration (during runtime pg envs are in
docker-compose)

This file is extracted in prod/staging/etc by
`./restore_pgbackrest_1.sh`

The current `.env.pg1` is for dev.

## Restore

Generally Speaking, on a fresh instance (e.g. staging) restore is
tricky. The key is to run pg1 without the internal scripts removing
`recovery.signal`, which is done with our hacky override `run.sh`.

Need a fresh **running** container for `docker exec` operations to
pull container ids.

1. create stanza: `backup_createstanza_pgbackrest.sh prod_db_stanza`
  * repo 1 - /mnt/pgbackrest (local instance store)
  * repo 2 - s3
2. Run sequence of restore operations
  * `./restore_pgbackrest_1.sh`: pgbackrest pulls from s3
  * `./restore_pgbackrest_2.sh`: starts pg container with `run.sh`
    that preserves `recovery.signal`. Cntrl-C out of db. <-- THIS IS
    THE KEY STEP IF DIFFICULTY RESTARTING DB. make sure to run via
    `run.sh` in this script.
  * `./restore_pgbackrest_3.sh`: cleans up and restarts service


### Restore Prod

```
ssh root@<db instance>

# on prod-db instance

cd release/abrepo
./restore_pgbackrest.sh

```

### Restore / Sync: Prod -> Staging

NB: Make sure to make a quick backup of `.env.pg1`: when things break
in the `restore_pgbackrest_*.sh` you will need these creds to rerun -
sometimes it may get overwritten with empty.


To restore:

```
ssh root@<db instance>

# on staging-db instance

cd releases/abrepo/
./backup_createstanza_pgbackrest.sh prod_db_stanza

./restore_pgbackrest_1.sh # be patient as it shuts down docker
./restore_pgbackrest_2.sh # will need to Cntrl-C to exit on success msg
./restore_pgbackrest_3.sh

```

`archive.conf`:

* Staging: abrepo_ops copies all files, but the staging env
  `stack.yml` does **not** bind mount `archive.conf` into the running
  `abrepo_pg1` container. So `archive-mode` is disabled by default in
  staging.

### Restore / Sync: Prod -> Dev

Pull from prod to local dev

1. `docker-compose.override.yml`: Comment out pg1 volume mounts: `./archive.conf`, `./run.sh`
2. Run Restore sequence (`./restore_pgbackrest_1.sh` ... 3.sh)
3. uncomment mount `./run.sh` to enable restore

To push to dev bcket

1. export PGBACKREST_REPO2_S3_BUCKET=abrepo-dev-web-pg-pgbackrest
2. create stanza, then exit
3. recomment ./run.sh and restart pg1
4. should be set to fresh backup to -dev bucket


## Backup

[Ansible](https://www.github.com/abrepo/abrepo_ops/ops/ansible/roles/cron/tasks/main.yml) sets
cron jobs to perform different backup operations.

1. Daily logical backup
2. Hourly pgbackrest incremental backup repo1 (instance store)
3. Hourly pgbackrest incremental backup repo2 (s3)
4. Daily full backup repo1
5. Daily full backup repo2

These are param changes that call the same script:
`~/dev/ab/abrepo/db/backup_pbackrest.sh <env> <stanza> <type> <repo#>`
