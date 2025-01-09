#!/usr/bin/env bash
REMOTE_RELEASE_PATH=/root/releases/abrepo/       # host path (for stack.yml mounts)
DEFAULT_DIR=~/dev/ab/abrepo_ops/releases/abrepo  # local release directory (ansible input)

DEPLOY_ENV=$1

if [ -z ${DEPLOY_ENV} ]; then
    echo "required deploy environment: [staging | production]"
    echo "e.g. './build.sh staging'"
    exit 1;
fi

# builds release stack.yml
mkdir -p $DEFAULT_DIR
mkdir -p $DEFAULT_DIR/db
mkdir -p $DEFAULT_DIR/nginx
mkdir -p $DEFAULT_DIR/haproxy
mkdir -p $DEFAULT_DIR/certbot

#
# CERT GEN / CHECK
#

./certbot/generate_certs.sh

#
# DOCKER BUILD
# build from app's local Dockerfile
#

#
# tag docker images with git commit
# currently skip checkout to avoid unnecessary detatched state
# just use HEAD as tag.
# But this May change on CI/CD server
GIT_COMMIT=$(git log -1 --format=%h)

# sudo needed to build nginx
REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
docker compose --env-file=.env build

# ecr creds
aws ecr get-login-password --region us-east-2 --profile abrepo | \
    docker login --password-stdin \
           --username AWS 976034468541.dkr.ecr.us-east-2.amazonaws.com

REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
docker compose --env-file=.env push

#build step, current artifact is just a stack.yml, but in future could be
#a tarball, etc.
echo "";
echo "building artifacts to $DEFAULT_DIR/"
echo "";

#
# Mark Deploy Environment
#

# remove previous mark
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
REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
docker compose -f docker-compose.yml -f docker-compose.$DEPLOY_ENV.yml \
                   config > $DEFAULT_DIR/stack.yml

#
# Misc Scripts and Config Files
#
echo "";
echo "copying database support files to $DEFAULT_DIR/"
echo "";

cp ./db/*.sh $DEFAULT_DIR/      # typically backup scripts
cp ./db/*.conf $DEFAULT_DIR/db/ # any conf overrides
cp ./nginx/*.template $DEFAULT_DIR/nginx # nginx
cp ./haproxy/*.cfg $DEFAULT_DIR/haproxy/ # haproxy

# generated certs are as root, require sudo
sudo cp ./certbot/letsencrypt/live/abrepo.com/fullchain.pem $DEFAULT_DIR/certbot/ #certs
sudo cp ./certbot/letsencrypt/live/abrepo.com/privkey.pem $DEFAULT_DIR/certbot/ #certs
sudo cat ./certbot/letsencrypt/live/abrepo.com/fullchain.pem ./certbot/letsencrypt/live/abrepo.com/privkey.pem > $DEFAULT_DIR/certbot/abrepo.pem

#
# If I want to add a different service configuration, build that into
# a separate stack.yml, but try to consisently deploying from a single point
# single file "compiled" at this build stage
#
#docker compose -f docker-compose.yml -f replica-pg2.yml \
#     config > $DEFAULT_DIR/stack-replica.yml


echo "";
ls -g $DEFAULT_DIR
ls -g $DEFAULT_DIR/db
ls -g $DEFAULT_DIR/nginx
ls -g $DEFAULT_DIR/haproxy

echo "";
