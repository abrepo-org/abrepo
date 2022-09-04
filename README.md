# ABRepo

Rails based frontend for abrepo web app


## Quickstart Initial Dev Setup

Because in dev we bind mount /app directory to local (so we don't have
to rebuild image to reflect changes via docker) we initially have to
some additional setup to get gems and webpacker loaded.

1. *Permissions*: For bitnami postgres image, requires chown user
directory 1001:1001 usually freezes because userid/grp is vergeman.

`sudo chown -R 1001:1001 /db`

2. install gems (e.g. complain ruby concurrency library missing - gems
   not registered)

3. assets/webpacker issue: missing assets - webpacker not installed:

```

`sudo docker-compose run web bash`

# 2. missing gems
bundle install

# 3. assets/webpacker issue
bundle exec rails webpacker:install
```

4. If db not initialized: while docker-compose is running, spin up
another web (rails container) and run migration.

```
RAILS_ENV=development rake db:setup

# for importer user
rake db:seed
```

Now `sudo docker-compose up` should work

---

## Ports: Haproxy, Nginx, Rails

### General Arch

* `www.abrepo.com` -> Cloudflare DNS points to floating ip.
* Cloudflare handles always-ssl automatic redirect from http -> https.
* DO has floating ip that we manually toggle between `app1`: lb ->
  nginx only, minimal config, and `lb1` - haproxy instance, when
  multiple backend nginx nodes needed.
* swarm listens to 443, which is forwarded to 8888 `haproxy` frontend.
* `haproxy` frontend proxies to backend `nginx` on 8080.
* Publicly visiting machine ip directly on port 80 is firewalled.
* `nginx` does expose port 80 internally, to receive haproxy
  requests. Port 80 is not exposed publicly.


#### Confguration Ports

* Config files: `haproxy/haproxy.cfg` and `haproxy/haproxy-dev.cfg`
* **Docker Swarm** config listens on 443, and targets (out) port 8888.
* `haproxy` frontend listens on 8888 -> and sends to 8080 (`nginx`
  backend)
* NB `haproxy` **cannot** directly bind to port `443` (conflict), so it's
  bound and set to listen on port `8888`. Effectively haproxy is an
  internal redirect, terminating ssl and round-robin port-forwarding
  from `frontend` ingress `8888` -> `backend` egress `8080` to `nginx`.
* Backend is directed to `nginx` service on port `8080`.

Nginx dev is on port 8080 to keep 80 open for swarm on localhost.

Nginx prod is on port 8080 as expected, swarm bound on 443 https.

#### Dev Ports

no ssl

visit http://localhost:80

| service                                            | ports     |
| -------                                            | ----------|
| docker swarm (via docker-compose.override:haproxy) | 80:8888   |
| haproxy (haproxy/haproxy-dev.cfg)                  | 8888:8080 |
| nginx (nginx.conf.dev.template)                    | 8080:8081 |
| rails (bundle exec rails s -p 8081)                | 8081      |


#### Staging and Production Ports

Current architecture has haproxy listening on 443, and nginx on 8080,
using ingress networking. Both are deployed as global services on
`app` and `lb` instance types. The idea is to have a minimal 1-node
'pod' of haproxy-nginx-app. To scale, these "pods" are duplicated
node, and are reverse-proxied behind a single `lb` node that runs only
haproxy. The fixed ip on digital ocean will then be toggled from a
single "pod" to the lb node.

This means there is an extra deployed haproxy service on each "pod"
that will be unused when the `lb` node is running. This is acceptable
because configuration is much easier, and there is redundancy if `lb`
node dies, can toggle fixed ip to a "pod" instance.


| service                                                                 | ports     |
| -------                                                                 | ----------|
| docker swarm (via docker-compose.haproxy)                               | 443:8888  |
| haproxy (global mode: haproxy/haproxy.cfg)                              | 8888:8080 |
| nginx   (global mode: docker-compose env port:8080)                     | 8080:8081 |
| rails   (bundle exec rails s)                                           | 8081      |


##### Previous Architecture Notes and Zero-Downtime Deploy Problem

Previously had nginx and haproxy in docker swarm host mode to "share"
port 443 across services. Idea was a minimal configuration ssl/static
served by nginx, and then to scale up with a dedicated `lb` node. Both
`haproxy and `nginx` would listen to 443 via networking host mode.

However this does not allow zero-downtime deloys: a rolling-update in
`start-first` order, results in a second container being started per
service, which in turn results in a port conflict. (Can't have 2 nginx
or haproxy on same port).

The current "pod" deploy `mode:global` architecture is to allow zero
downtime deploy via `start-first` order. The tradeoff is extra haproxy
service on each node, but since they won't be actively used (traffic
only to `lb` instance), the resource footprint should be minimal.



### Haproxy

Haproxy is a mode:global, single load balancer service deployed to
each `lb` and `app`.  Serves as the single ingress point to to `nginx`.

Each "pod" has a haproxy instance for redundancy and deployment
configuration ease. On scale, ideally the "pod" haproxy instances are
not used. Traffic (via fixed ip) is directed to a single `lb` instance
which uses swarm mesh to route to nginx services (and rails)

Needed to round robin once there are multiple app instances. Lives on
its own instance (lb).


### Nginx

Nginx also deployed mode:global.

Nginx is our web server; port is dynamically configured (internal
script) via `NGINX_PORT` environmental variable, which internally uses
`envsubst` to rewrite the `nginx.conf.template` and output a populated
`default.conf` file within the container on startup.

* `nginx/nginx_conf.template`
* dev and prod env: listens http port 8080



## Dev: ECR Pull Image and Build (setup for Docker Push)


[Dev] Add access to aws ecr credential helper:

1. clone repo git@github.com:awslabs/amazon-ecr-credential-helper
2. `make docker` builds binary
3. `sudo mv /bin/docker-credential-ecr-login /usr/local/bin`
4. copy over `./docker/.config.json`:

```
# .config.json
{
    "auths": {
	"https://index.docker.io/v1/": {
	    "auth": "<add this>"
	}
    },
    "HttpHeaders": {
	"User-Agent": "Docker-Client/18.06.1-ce (linux)"
    },
    "credHelpers": {
	"<my-repo>.dkr.ecr.<my-region>.amazonaws.com": "ecr-login"
    }
}

```


To pull image:

make sure access to aws ECR to pull image (keys in .env)


```
sudo `< .env` docker-compose pull
```

To build:

```
sudo docker-compose build
```

To run stack:

```
sudo docker-compose up
```

install gems for local dev run (volume map)

```
sudo docker-compose run web bash

# run in container to populate /app/bundler locally

bundle install
```


---

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

## Build vs Deploy Dependencies

Static Assets are served from nginx

#### Build

`nginx` docker-compose.yml `depends_on` ensures that `web` (abrepo) is
built first, so that `nginx` can copy the static files from that image
(they are served from nginx)

#### Deploy

Conversely, `web` depends on `nginx` to start first in
production. `nginx` image keeps copies of previous deployed static
assets, so it is backward compatible. If we ran `web` first, it would
request static assets in the `nginx` service that might not exist
(pending new update.)

## Rolling Updates

`docker stack deploy` will apply the `deploy.update_config` pattern:

https://docs.docker.com/compose/compose-file/compose-file-v3/#update_config

`update_config.order:start-first` allows new container to load first,
then replace the running container.

NB: `commit --amend` and deploys will mess up container tag
structure. Just do sequential commits onto a deploy branch (master,
feature-flag). Working branch amends are fine.

## Migrations

For schema migrations:

* `runtime` ansible group executes `rake db:migrate` on `app1`: `./docker_ansible_<env>.sh runtime`
* for data migrations, need to ssh, exec into container and run rake task:

```

docker ps  # get abrepo_web container id
docker exec -it <container id> bash
rake -T # task list
rake <abrepo:taskname>

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



## Rails Notes

* Need to rebuild image when doing a gem bundle install (standalone
  bundle install installs, but docker run is ephemeral)


* Permission issues? Try clearing cache generated as route.

#### Rails & Docker Updates


* ruby version is managed by Dockerfile; make sure to change
  `.ruby-version`, and `ruby` gem version in `Gemfile`.
* nodesource: https://github.com/nodesource/distributions#deb - also
  installed via Dockerfile, alongside `yarn`.
* `docker-compose build`: for `bundler` and `ruby` upgrades: have to
  comment out Gemfile.lock `COPY Gemfile.lock` directive in
  `Dockerfile` to ensure the same (systems) installed versions.
* Other gems can be upgraded in Gemfile - simpy need to run `bundle
  install` in docker shell to generate the Gemfile.lock. Make sure
  Dockerfile copies it over so its used in `docker-compose build`.
* `entrypoint.sh` may or may not be a good place to put init scripts on
  upgrade (they can break) e.g update_attributes() -> update()


#### Rails + Webpack

No longer use sprockets, replaced with webpack

https://mariochavez.io/desarrollo/2020/05/19/from-the-asset-pipeline-to-webpack.html

Commands:
rails g webpacker:install
rails g webpacker:install:react

Move asset directories:

* app/assets/javascript -> app/javascript/packs
* app/assets/stylesheets -> /app/javascript/stylesheets/
* app/assets/images/  -> app/javascript/images
* app/assets: basically becomes empty directory

Change vews/layouts/application.html.erb to reference load pack tags:

* stylesheet_tag --> stylesheet_pack_tag
* javascript_tag --> javascript_pack_tag


Change assets (scss, images) to be packed in `/javscript/packs/application.js`:

```
# scss
import "../stylesheets/application.scss"

# static images
const images = require.context('../images', true)
const imagePath = (name) => images(name, true)

# .jsx - relative path is important
import "./hello_react.jsx"
import Hello from "./hello_react.jsx"

```


```
#javascript/packs/application.js
import "../stylesheets/application.scss"

#application.scss:
#example of loading module
import "body.scss"

```

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
