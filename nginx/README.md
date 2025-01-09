# NGINX

* Sits in front of rails and serves static files
* load balances puma servers

To serve static files (and pass config) we need to package them into our own
custom nginx container. This is rebuilt and deployed alongside rails app each
time. [../build.sh](see root /build.sh)

NB: Sprockets keeps 3 versions of rails compiled assets, so rollout deploy "lag"
where requests can hit multiple running versions of rails is OK.

# Haproxy

Used for ssl termination with letsencrypt cert. Points to nginx.
