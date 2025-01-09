# Docker + Rails: Build / Deploy Dependencies

#### Build

`nginx` `depends_on` ensures that `web` is built first, so that `nginx` can copy
the rails static files built from that image (they are served from nginx)

#### Deploy

Conversely, `web` depends on `nginx` to start first in production. `nginx` image
keeps copies of previous deployed static assets, so it is backward compatible.

If we ran `web` first, there might be static assets requests that are
unavailable since `nginx` doesn't exist (pending new update.)

---

## Rolling Updates

`docker stack deploy` will apply the `deploy.update_config` pattern:

https://docs.docker.com/compose/compose-file/compose-file-v3/#update_config

`update_config.order:start-first` allows new container to load first, then
replace the running container.

NB: `commit --amend` and deploys will mess up container tag structure. Just do
sequential commits onto a deploy branch (master, feature-flag). Working branch
amends are fine.

## Remote Rake: Migrations

For schema migrations:

* `runtime` ansible group executes `rake db:migrate` on `app1`:
  `./docker_ansible_<env>.sh runtime`
* data migrations for now ssh, exec into container and run rake task:


```
docker ps  # get abrepo_web container id
docker exec -it <container id> bash
rake -T # task list
rake <abrepo:taskname>
```

---

## Rails & Docker Updates

* ruby version is managed by Dockerfile; make sure to change `.ruby-version`,
  and `ruby` gem version in `Gemfile`.

* nodesource: https://github.com/nodesource/distributions#deb - also installed
  via Dockerfile, alongside `yarn`.

* `docker-compose build`: for `bundler` and `ruby` upgrades: have to comment out
  Gemfile.lock `COPY Gemfile.lock` directive in `Dockerfile` to ensure the same
  (systems) installed versions.

* Other gems can be upgraded in Gemfile - simpy need to run `bundle install` in
  docker shell to generate the Gemfile.lock. Make sure Dockerfile copies it over
  so its used in `docker-compose build`.

* `entrypoint.sh` may or may not be a good place to put init scripts on upgrade
  (they can break) e.g update_attributes() -> update()

* Need to rebuild image when doing a gem bundle install (standalone bundle
  install installs, but docker run is ephemeral)

* Permission issues? Try clearing cache generated as route.


## Install Postgres in Rails + Docker

General instructions: https://docs.docker.com/compose/rails/

``` bash
# 1. add 'pg', or adding any gem to Gemfile,

#open Gemfile
gem 'pg'

# 2. install bundle:

docker-compose build

# 3. update config/database.yml
#  important to note host is "db" which is a docker-compose generated host variable
#  so 'db' host is unknown when using 'docker run' or similar

docker-compose run -e RAILS_ENV=development web rake db:setup

# fix permissions /tmp/db
sudo chown -R $USER:$USER .


# 5. Note: postgres uses a bind mount volume ./tmp/db on host
# to internally mapping to default directory /var/lib/postgresql/data

```


---


## ECR Repository

Frequently need to re-auth. Once auth'd, just `docker push` the image.

```
aws ecr get-login-password --region <region> --profile <profile> | \
    docker login --password-stdin \
           --username AWS <account>.dkr.ecr.<region>.amazonaws.com

```


#### AWS CLI Install

https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```


---

## Docker Compose Healthcheck

Typical check run via docker-compose. Operates in all env; dev, prod, etc:

```
# web, nginx
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

`docker inspect abrepo_web_1 --format='{{json .State.Health}}'  | jq`


---

## Portainer (No longer used)

For "external" 3rd party vendor services to be added to stack, easier
to have separate stack.yml file
e.g. [Portainer](https://www.portainer.io/installation/) and "attach"
to running stack:

```
$ curl -L https://downloads.portainer.io/portainer-agent-stack.yml -o portainer-agent-stack.yml
$ docker stack deploy --compose-file=portainer-agent-stack.yml abrepo
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
