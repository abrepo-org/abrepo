# ABRepo

Rails based frontend for abrepo web app

## Quickstart

*Permissions*: For bitnami postgres image, requires chown user
directory 1001:1001 usually freezes because userid/grp is vergeman.

```
sudo chown -R 1001:1001 /db

```

To run stack:

```
sudo docker-compose up
```

If db not initialized: while docker-compose is running, spin up
another web (rails container) and run migration.

```
sudo docker-compose run web bash
RAILS_ENV=development rake db:setup

```

---

Piecemeal runs:

```
sudo docker-compose -f replica-pg2.yml -f docker-compose.yml up

sudo docker stack deploy -c replica-pg2.yml -c docker-compose.yml <stack name>

```

For shell, once off commands

```
#careful about db permissions
./docker_run bash

#alternatively
sudo docker-compose run web <CMD>
```

For "external" 3rd party vendor services to be added to stack, easier
to have separate stack.yml file
e.g. [Portainer](https://www.portainer.io/installation/) and "attach"
to running stack:

```
$ curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
$ docker stack deploy --compose-file=portainer-agent-stack.yml abrepo
```


## Install Postgres in Rails + Docker

General instructions: https://docs.docker.com/compose/rails/

``` bash
# 1. add 'pg', or adding any gem to Gemfile,

#open Gemfile
gem 'pg'

# 2. install bundle:

sudo docker-compose build

# 3. update config/database.yml
#  important to note host is "db" which is a docker-compose generated host variable
#  so 'db' host is unknown when using 'docker run' or similar

sudo docker-compose run -e RAILS_ENV=development web rake db:setup

# fix permissions /tmp/db
sudo chown -R $USER:$USER .


# 5. Note: postgres uses a bind mount volume ./tmp/db on host as internally
mapping to default directory /var/lib/postgresql/data

```

#### Healthcheck

Typical check run via docker-compose. Operates in all env; dev, prod, etc:

```

#traefik - needs an endpoint setup
test: "wget -q -O- localhost:8082/ping || exit 1"

#web, nginx
healthcheck:
  test: ["CMD-SHELL",
    "curl -o /dev/null -I -f -s -w %{http_code} http://localhost:8081/?healthcheck=true || exit 1"]
  interval: 1
  timeout: 1m30s
  retries: 3

#pg
  test: ["CMD-SHELL", "pg_isready -U postgres"]
```


Look at status:

`sudo docker inspect abrepo_web_1 --format='{{json .State.Health}}'  | jq`


#### PSQL info on creating user

Update: don't really need all this below.

Just need to init with a `RAILS_ENV=x rake db:setup`.


```


## Rails Notes

* Need to rebuild image when doing a gem bundle install (standalone
  bundle install installs, but docker run is ephemeral)


* Permission issues? Try clearing cache generated as route.

```
(sudo) rake tmp:cache:clear
```



#### Portainer / Monitoring

Open port 9000 on firewall for web interface

Deploy as a separate stack on master node. Agent needed on each node
to get stats.

Leaks a lot of info (env etc) and what I need can be done on command line.


```
$ curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
$ docker stack deploy --compose-file=portainer-agent-stack.yml portainer
```
