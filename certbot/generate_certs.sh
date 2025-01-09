#!/usr/bin/env bash

#
# for wildcard *.abrepo.com
#
docker run \
       -v /home/vergeman/dev/ab/abrepo/certbot/letsencrypt:/etc/letsencrypt \
       -it certbot/dns-cloudflare:latest certonly --dns-cloudflare \
       --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
       -d *.abrepo.com


