#!/usr/bin/env bash

#builds release stack.yml
DEFAULT_DIR=~/dev/ab/abrepo_ops/releases/abrepo
mkdir -p $DEFAULT_DIR

#build from app's local Dockerfile
sudo docker-compose build

sudo `< .env` docker-compose push

#build step, current artifact is just a stack.yml, but in future could be
#a tarball, etc.
echo "";
echo "building artifacts to $DEFAULT_DIR/"
echo "";

sudo docker-compose -f docker-compose.yml config > $DEFAULT_DIR/stack.yml

echo "";
ls -g $DEFAULT_DIR
echo "";
