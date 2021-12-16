#!/usr/bin/env bash
REMOTE_RELEASE_PATH=/root/releases/abrepo/       # host path (for stack.yml mounts)
DEFAULT_DIR=~/dev/ab/abrepo_ops/releases/abrepo  # local release directory (ansible input)

DEPLOY_ENV="$@"
if [ -z ${DEPLOY_ENV} ]; then
    echo "required deploy environment: [staging | production]"
    echo "e.g. './build.sh staging'"
    exit 1;
fi


# builds release stack.yml
mkdir -p $DEFAULT_DIR
mkdir -p $DEFAULT_DIR/db

#build from app's local Dockerfile
sudo `< .env` \
     REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
     docker-compose build

sudo `< .env` \
     REMOTE_RELEASE_PATH=$REMOTE_RELEASE_PATH \
     docker-compose push

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
                   docker-compose -f docker-compose.yml -f docker-compose.$DEPLOY_ENV.yml \
                   config > $DEFAULT_DIR/stack.yml

#
# Misc Scripts
#
echo "";
echo "copying database support files to $DEFAULT_DIR/"
echo "";

cp ./db/*.sh $DEFAULT_DIR/      # typically backup scripts
cp ./db/*.conf $DEFAULT_DIR/db/ # any conf overrides
#
# If I want to add a different service configuration, build that into
# a separate stack.yml, but try to consisently deploying from a single point
# single file "compiled" at this build stage
#
#sudo docker-compose -f docker-compose.yml -f replica-pg2.yml \
#     config > $DEFAULT_DIR/stack-replica.yml


echo "";
ls -g $DEFAULT_DIR
ls -g $DEFAULT_DIR/db
echo "";
