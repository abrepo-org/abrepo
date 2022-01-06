# Certbot Notes

Use Letsencrypt + Certbot on Cloudflare.

Certbot anticipates two forms of challenge to generate a certificate:

* dns
* http

We use `dns` via Cloudflare since it's the only way to
get a wildcard cert.

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

sudo docker run \
    -v /home/vergeman/dev/ab/abrepo/certbot/letsencrypt:/etc/letsencrypt \
    -it certbot/dns-cloudflare:latest certonly --dns-cloudflare \
    --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
    -d *.abrepo.com


#Certificate is saved at: ./letsencrypt/live/staging.abrepo.com/fullchain.pem
#Key is saved at:         ./letsencrypt/live/staging.abrepo.com/privkey.pem

```

## Build

* `./build.sh` copies cert to release directory, ansible uploads to
  each app server
* the docker-compose files bind volume to `/etc/letsencrypt/live/abrepo.com/`
