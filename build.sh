#!/usr/bin/env bash
REMOTE_RELEASE_PATH=/root/releases/abrepo/           # host path (for stack.yml mounts)
DEFAULT_DIR=$HOME/dev/ab/abrepo_ops/releases/abrepo  # local release directory for stack.yml (ansible input)

DEPLOY_ENV=$1

if [ -z ${DEPLOY_ENV} ]; then
    echo "required deploy environment: [staging | production]"
    echo "e.g. './build.sh staging'"
    exit 1;
fi

if [ -f .env ]; then
    source .env
fi

AWS_ECR_PROFILE=$AWS_ECR_PROFILE
AWS_ECR_REGION=$AWS_ECR_REGION
AWS_ECR_ACCOUNT=$AWS_ECR_ACCOUNT
WEB_IMAGE=$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com/abrepo/abrepo
NGINX_IMAGE=$AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com/abrepo/abnginx

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

REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
docker compose --env-file=.env build

# tag
echo "tagging $WEB_IMAGE:$GIT_COMMIT"
docker tag abrepo/abrepo:$GIT_COMMIT $WEB_IMAGE:$GIT_COMMIT

echo "tagging $NGINX_IMAGE:$GIT_COMMIT"
docker tag abrepo/abnginx:$GIT_COMMIT $NGINX_IMAGE:$GIT_COMMIT

# ecr creds
aws ecr get-login-password --region $AWS_ECR_REGION --profile $AWS_ECR_PROFILE | \
    docker login --password-stdin \
           --username AWS $AWS_ECR_ACCOUNT.dkr.ecr.$AWS_ECR_REGION.amazonaws.com

REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
WEB_IMAGE=$WEB_IMAGE \
NGINX_IMAGE=$NGINX_IMAGE \
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
# NB: docker compose config now generates a less rigorous stack.yml that
# conflicts with docker swarm expected yml format.
#
# 1. remove generated 'name' field in stack.yml
# 2. replace published ports from string to number (config errantly auto
# generates quotes)
#
REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
GIT_COMMIT=$GIT_COMMIT \
WEB_IMAGE=$WEB_IMAGE \
NGINX_IMAGE=$NGINX_IMAGE \
docker compose -f docker-compose.yml -f docker-compose.$DEPLOY_ENV.yml \
                   config | grep -v '^name:' \
    | sed 's/published: "\([0-9]*\)"/published: \1/'  > $DEFAULT_DIR/stack.yml

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
