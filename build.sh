#!/usr/bin/env bash

DEPLOY_ENV="$@"
if [ -z ${DEPLOY_ENV} ]; then
    echo "required deploy environment: [staging | production]"
    echo "e.g. './build.sh staging'"
    exit 1;
fi


#builds release stack.yml
DEFAULT_DIR=~/dev/ab/abrepo_ops/releases/abrepo
mkdir -p $DEFAULT_DIR
mkdir -p $DEFAULT_DIR/db

#build from app's local Dockerfile
sudo `< .env` docker-compose build

sudo `< .env` docker-compose push

#build step, current artifact is just a stack.yml, but in future could be
#a tarball, etc.
echo "";
echo "building artifacts to $DEFAULT_DIR/"
echo "";

#
# Mark Deploy Environment
#

if [ -f $DEFAULT_DIR/.production ] ; then
    rm "$DEFAULT_DIR/.production"
fi

if [ -f $DEFAULT_DIR/.staging ] ; then
    rm "$DEFAULT_DIR/.staging"
fi

touch "$DEFAULT_DIR/.$DEPLOY_ENV"


#
# Create singular deploy stack.yml file given environment param
# combing docker-compose.staging.yml or docker-compose.production.yml
#
sudo docker-compose -f docker-compose.yml -f docker-compose.$DEPLOY_ENV.yml \
     config > $DEFAULT_DIR/stack.yml

#
# Misc Scripts
#
echo "";
echo "copying database support files to $DEFAULT_DIR/"
echo "";

sudo cp ./db/*.sh $DEFAULT_DIR/      # typically backup scripts
sudo cp ./db/*.conf $DEFAULT_DIR/db/ # any conf overrides
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
