#!/usr/bin/env bash

#builds release stack.yml
DEFAULT_DIR=~/dev/ab/abrepo_ops/releases/abrepo
mkdir -p $DEFAULT_DIR

#build from app's local Dockerfile
sudo `< .env` docker-compose build

sudo `< .env` docker-compose push

#build step, current artifact is just a stack.yml, but in future could be
#a tarball, etc.
echo "";
echo "building artifacts to $DEFAULT_DIR/"
echo "";

#
# Maintain stack.yml as a singular deploy file
#
sudo docker-compose -f docker-compose.yml config > $DEFAULT_DIR/stack.yml

#
# If I want to add a different service configuration, build that into
# a separate stack.yml, but try to consisently deploying from a single point
# single file "compiled" at this build stage
#
#sudo docker-compose -f docker-compose.yml -f replica-pg2.yml \
#     config > $DEFAULT_DIR/stack-replica.yml


echo "";
ls -g $DEFAULT_DIR
echo "";
