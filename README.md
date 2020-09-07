# ABRepo

Rails based frontend for abrepo web app

## Quickstart

To run stack:

```
sudo docker-compose up
```

For shell, once off commands

```
./docker_run bash

#alternatively
sudo docker-compose run web <CMD>
```


## Postgres in Rails + Docker

General instructions: https://docs.docker.com/compose/rails/

``` bash
# 1. add 'pg' to Gemfile,
# 2. install bundle:

sudo docker-compose build

# 3. update config/database.yml
#  important to note host is "db" which is a docker-compose generated host variable
#  so 'db' host is unknown when using 'docker run' or similar

# 4. create db, run migrations: `rake db:migrate` `rake db:setup`

sudo docker-compose run web rake db:create
sudo docker-compose run web rake db:setup
sudo docker-compose run web rake db:migrate

# fix permissions /tmp/db
sudo chown -R $USER:$USER .


# 5. Note: postgres uses a bind mount volume ./tmp/db on host as internally
mapping to default directory /var/lib/postgresql/data

```

#### PSQL info on creating user

Update: don't really need all this below.

Just need to init with a `RAILS_ENV=x rake db:setup`.

```
# pg admin users
su - postgres
psql

create role rails_dev with createdb login password 'password1';
\du

#add creds above (rails_dev, password1) to config/database.yml

```


## Rails Notes

* Need to rebuild image when doing a gem bundle install (standalone
  bundle install installs, but docker run is ephemeral)


* Permission issues? Try clearing cache generated as route.

```
(sudo) rake tmp:cache:clear
```
