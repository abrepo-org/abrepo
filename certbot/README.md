# Certbot Notes

Use Letsencrypt + Certbot on Cloudflare.

Certbot anticipates two forms of challenge to generate a certificate:

* dns
* http

We use `dns` via Cloudflare.

## Cloudflare API Token

Get API token permissioned only for `Zone::DNS::Edit`. Avoid using
global key if possible.

## Docker Image

Docker has a certbot dns plugin for Cloudflare.

Bind volume to expose `cloudflare.ini` inside container:
`($pwd)/certbot/letsencrypt/:/etc/letsencrypt/` so
`/etc/letsencrypt/cloudflare.ini` becomes config address.


```
docker pull certbot/dns-cloudflare:latest

# generate or renew creds

docker run \
       -v /home/vergeman/dev/ab/abrepo/certbot/letsencrypt:/etc/letsencrypt \
       -it certbot/dns-cloudflare:latest certonly --dns-cloudflare \
       --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
       -d *.abrepo.com


# Certificate is saved at: ./letsencrypt/live/abrepo.com/fullchain.pem
# Key is saved at:         ./letsencrypt/live/abrepo.com/privkey.pem

```

## Build

* `./build.sh` copies certs to release directory, and ansible rsyncs
  to each server
* For haproxy there is a required combined key step: `cat
  fullchain.pem privkey.pem > abrepo.pem` (just how it takes it)
* Files are bind volume to `/etc/letsencrypt/live/abrepo.com/`, as
  indicated in docker-compose.yml
* Both nginx and haproxy use the same cert.
* Certs are wildcard domain (*.abrepo.com) and serve both
  www.abrepo.com, staging.abrepo.com
