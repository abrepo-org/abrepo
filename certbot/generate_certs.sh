#!/usr/bin/env bash

#
# for wildcard *.abrepo.com
#
BASE_DIR=$(dirname "$(realpath "$BASH_SOURCE")")

docker run \
       -v $BASE_DIR/letsencrypt:/etc/letsencrypt \
       -it certbot/dns-cloudflare:latest certonly --dns-cloudflare \
       --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini \
       -d *.abrepo.com
