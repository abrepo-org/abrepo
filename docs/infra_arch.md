## Infra General Arch

* `www.abrepo.com` -> Cloudflare DNS points to floating ip.

* Cloudflare handles always-ssl automatic redirect from http -> https.

* DO has floating ip that we manually toggle between `app1`: lb -> nginx only,
  minimal config, and `lb1` - haproxy instance, when multiple backend nginx
  nodes needed.

* 443 forwards to 8888 `haproxy` frontend.

* `haproxy` frontend proxies to backend `nginx` on 8080.
  * Publicly visiting machine ip directly on port 80 is fire-walled.

* `nginx` does expose port 80 internally, to receive haproxy
  requests. Port 80 is not exposed publicly.


### Confguration Ports

* Config files: `haproxy/haproxy.cfg` and `haproxy/haproxy-dev.cfg`

* **Docker Swarm** config listens on 443, and targets (out) port 8888.

* `haproxy` frontend listens on 8888 -> and sends to 8080 (`nginx`
  backend)

* NB `haproxy` **cannot** directly bind to port `443` (conflict), so it's bound
  and set to listen on port `8888`. Effectively haproxy is an internal redirect,
  terminating ssl and round-robin port-forwarding from `frontend` ingress `8888`
  -> `backend` egress `8080` to `nginx`.

* Backend is directed to `nginx` service on port `8080`.

Nginx dev is on port 8080 to keep 80 open for swarm on localhost.

Nginx prod is on port 8080 as expected, swarm bound on 443 https.


#### Dev Ports

no ssl

visit http://localhost:80

| service                                            | ports     |
|----------------------------------------------------|-----------|
| docker swarm (via docker-compose.override:haproxy) | 80:8888   |
| haproxy (haproxy/haproxy-dev.cfg)                  | 8888:8080 |
| nginx (nginx.conf.dev.template)                    | 8080:8081 |
| rails (bundle exec rails s -p 8081)                | 8081      |


#### Staging and Production Ports

Current architecture has haproxy listening on 443, and nginx on 8080, using
ingress networking. Both are deployed as global services on `app` and `lb`
instance types. The idea is to have a minimal 1-node 'pod' of haproxy-nginx-app.
To scale, these "pods" are duplicated node, and are reverse-proxied behind a
single `lb` node that runs only haproxy. The fixed ip on digital ocean will then
be toggled from a single "pod" to the lb node.

This means there is an extra deployed haproxy service on each "pod" that will be
unused when the `lb` node is running. This is acceptable because configuration
is much easier, and there is redundancy if `lb` node dies, can toggle fixed ip
to a "pod" instance.


| service                                             | ports     |
|-----------------------------------------------------|-----------|
| docker swarm (via docker-compose.haproxy)           | 443:8888  |
| haproxy (global mode: haproxy/haproxy.cfg)          | 8888:8080 |
| nginx   (global mode: docker-compose env port:8080) | 8080:8081 |
| rails   (bundle exec rails s)                       | 8081      |


### Haproxy

Haproxy is a mode:global, single load balancer service deployed to each `lb` and
`app`. Serves as the single ingress point to to `nginx`.

Each "pod" has a haproxy instance for redundancy and deployment configuration
ease. On scale, ideally the "pod" haproxy instances are not used. Traffic (via
fixed ip) is directed to a single `lb` instance which uses swarm mesh to route
to nginx services (and rails)

Needed to round robin once there are multiple app instances. Lives on its own
instance (lb).

### Nginx

Nginx also deployed mode:global.

Nginx is our web server; port is dynamically configured (internal script) via
`NGINX_PORT` environmental variable, which internally uses `envsubst` to rewrite
the `nginx.conf.template` and output a populated `default.conf` file within the
container on startup.

* `nginx/nginx_conf.template`
* dev and prod env: listens http port 8080


